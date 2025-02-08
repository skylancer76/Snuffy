//
//  FirebaseManager.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation
import UIKit

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // MARK: - Pet Data Functions
    
    /// Save pet data to Firestore with a unique petId.
    func savePetDataToFirebase(data: [String: Any], petId: String, completion: @escaping (Error?) -> Void) {
        let collection = db.collection("Pets")
        collection.document(petId).setData(data) { error in
            if let error = error {
                print("Failed to save pet data: \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Caretaker Data Functions
    
    /// Save caretaker data to Firestore.
    func saveCaretakerData(caretakers: [Caretakers], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        
        for caretaker in caretakers {
            let caretakerRef = db.collection("caretakers").document(caretaker.caretakerId)
            group.enter()
            
            // Upload Profile Picture
            uploadProfileImage(imageName: caretaker.profilePic, caretakerId: caretaker.caretakerId) { profileImageUrl, error in
                if let error = error {
                    completion(error)
                    group.leave()
                    return
                }
                
                var updatedCaretaker = caretaker
                updatedCaretaker.profilePic = profileImageUrl ?? ""
                
                self.saveCaretakerToFirestore(caretaker: updatedCaretaker, caretakerRef: caretakerRef) { error in
                    completion(error)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(nil)
        }
    }
    
    /// Helper function to encode and save a caretaker object.
    func saveCaretakerToFirestore(caretaker: Caretakers, caretakerRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(caretaker)
            caretakerRef.setData(data) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    /// Upload a caretaker's profile image to Firebase Storage.
    func uploadProfileImage(imageName: String, caretakerId: String, completion: @escaping (String?, Error?) -> Void) {
        guard let image = UIImage(named: imageName) else {
            completion(nil, NSError(domain: "ImageError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found in assets"]))
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_pictures/\(caretakerId).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(url?.absoluteString, nil)
                    }
                }
            }
        } else {
            completion(nil, NSError(domain: "ImageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))
        }
    }
    
    // MARK: - Schedule Request Functions
    
    /// Save schedule request data to Firestore.
    func saveScheduleRequestData(data: [String: Any], completion: @escaping (Error?) -> Void) {
        let collection = db.collection("scheduleRequests")
        if let requestId = data["requestId"] as? String {
            collection.document(requestId).setData(data) { error in
                completion(error)
            }
        } else {
            completion(NSError(domain: "",
                               code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "Missing requestId in data"]))
        }
    }
    
    /// Auto-assign a caretaker based on the provided petName, requestId, and optionally the user's location.
    func autoAssignCaretaker(petName: String, requestId: String, userLocation: CLLocation?, completion: @escaping (Error?) -> Void) {
        db.collection("Pets").whereField("petName", isEqualTo: petName).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let petDoc = snapshot?.documents.first else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pet not found"]))
                return
            }
            
            guard let ownerId = petDoc.data()["ownerID"] as? String else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Owner ID not found in pet document"]))
                return
            }
            
            guard let currentUserId = Auth.auth().currentUser?.uid, currentUserId == ownerId else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user is not the owner of the pet"]))
                return
            }
            
            // Use the provided userLocation from the Add Address page if available.
            if let providedLocation = userLocation {
                self.assignCaretaker(using: providedLocation, requestId: requestId, completion: completion)
            } else {
                // Fallback: fetch the location from the user's Firestore document.
                self.db.collection("users").document(ownerId).getDocument { (userSnapshot, error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    guard let userData = userSnapshot?.data() else {
                        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"]))
                        return
                    }
                    
                    var fetchedLocation: CLLocation?
                    if let userGeoPoint = userData["location"] as? GeoPoint {
                        fetchedLocation = CLLocation(latitude: userGeoPoint.latitude, longitude: userGeoPoint.longitude)
                    } else if let locationMap = userData["location"] as? [String: Any],
                              let lat = locationMap["latitude"] as? Double,
                              let lon = locationMap["longitude"] as? Double {
                        fetchedLocation = CLLocation(latitude: lat, longitude: lon)
                    } else if let locationArray = userData["location"] as? [Double],
                              locationArray.count >= 2 {
                        fetchedLocation = CLLocation(latitude: locationArray[0], longitude: locationArray[1])
                    }
                    
                    guard let loc = fetchedLocation else {
                        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User location not found"]))
                        return
                    }
                    
                    self.assignCaretaker(using: loc, requestId: requestId, completion: completion)
                }
            }
        }
    }
    
    /// Helper function to perform caretaker assignment using a given location.
    private func assignCaretaker(using userLocation: CLLocation, requestId: String, completion: @escaping (Error?) -> Void) {
        db.collection("caretakers").whereField("status", isEqualTo: "available").getDocuments { (caretakerSnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let caretakerDocs = caretakerSnapshot?.documents else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No available caretakers found"]))
                return
            }
            
            let sortedCaretakers = caretakerDocs.compactMap { doc -> (DocumentReference, Caretakers, Double)? in
                let data = doc.data()
                guard let caretaker = try? Firestore.Decoder().decode(Caretakers.self, from: data) else {
                    print("Decoding failed for document: \(doc.documentID)")
                    return nil
                }
                
                var caretakerLocation: CLLocation?
                if let caretakerGeoPoint = data["location"] as? GeoPoint {
                    caretakerLocation = CLLocation(latitude: caretakerGeoPoint.latitude, longitude: caretakerGeoPoint.longitude)
                } else if let locationMap = data["location"] as? [String: Any],
                          let lat = locationMap["latitude"] as? Double,
                          let lon = locationMap["longitude"] as? Double {
                    caretakerLocation = CLLocation(latitude: lat, longitude: lon)
                } else if let locationArray = data["location"] as? [Double],
                          locationArray.count >= 2 {
                    caretakerLocation = CLLocation(latitude: locationArray[0], longitude: locationArray[1])
                }
                
                guard let caretakerLocation = caretakerLocation else {
                    print("Location not found or invalid for caretaker: \(caretaker.caretakerId)")
                    return nil
                }
                
                let distanceInMeters = userLocation.distance(from: caretakerLocation)
                let distanceInKm = distanceInMeters / 1000.0
                let safeDistance = distanceInKm > 0 ? distanceInKm : 0.001
                let score = Double(caretaker.experience) / safeDistance
                return (doc.reference, caretaker, score)
            }
            .sorted { $0.2 > $1.2 }
            
            guard let (selectedCaretakerRef, selectedCaretaker, _) = sortedCaretakers.first else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No suitable caretakers found"]))
                return
            }
            
            print("Assigning request \(requestId) to caretaker: \(selectedCaretaker.name) (Exp: \(selectedCaretaker.experience))")
            
            let requestRef = self.db.collection("scheduleRequests").document(requestId)
            requestRef.updateData([
                "caretakerId": selectedCaretaker.caretakerId,
                "status": "pending"
            ]) { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                selectedCaretakerRef.updateData([
                    "pendingRequests": FieldValue.arrayUnion([requestId])
                ]) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        print("Request successfully assigned to \(selectedCaretaker.name)")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch Requests & Bookings
    
    /// Fetch assigned requests for a caretaker.
    func fetchAssignedRequests(for caretakerId: String, completion: @escaping ([ScheduleRequest]) -> Void) {
        db.collection("scheduleRequests")
            .whereField("caretakerId", isEqualTo: caretakerId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching schedule requests: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var requests: [ScheduleRequest] = []
                let group = DispatchGroup()
                
                for document in snapshot?.documents ?? [] {
                    var requestData = document.data()
                    requestData["requestId"] = document.documentID
                    
                    guard let petName = requestData["petName"] as? String else { continue }
                    
                    group.enter()
                    self.db.collection("Pets")
                        .whereField("petName", isEqualTo: petName)
                        .getDocuments { petSnapshot, error in
                            if let error = error {
                                print("Error fetching pet ID for \(petName): \(error.localizedDescription)")
                                group.leave()
                                return
                            }
                            
                            guard let petDocument = petSnapshot?.documents.first else {
                                print("No pet found for name: \(petName)")
                                group.leave()
                                return
                            }
                            
                            let petId = petDocument.documentID
                            requestData["petId"] = petId
                            let petData = petDocument.data()
                            
                            requestData["petBreed"] = petData["petBreed"] as? String ?? "Unknown"
                            requestData["petImageUrl"] = petData["petImage"] as? String ?? ""
                            
                            if let scheduleRequest = ScheduleRequest(from: requestData) {
                                requests.append(scheduleRequest)
                            }
                            
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    completion(requests)
                }
            }
    }
    
    /// Fetch booking details for a pet owner.
    func fetchOwnerBookings(for userId: String, completion: @escaping ([ScheduleRequest]) -> Void) {
        db.collection("scheduleRequests")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching bookings: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var requests: [ScheduleRequest] = []
                for document in snapshot?.documents ?? [] {
                    var requestData = document.data()
                    requestData["requestId"] = document.documentID
                    // Convert to ScheduleRequest model
                    if let scheduleRequest = ScheduleRequest(from: requestData) {
                        requests.append(scheduleRequest)
                    }
                }
                completion(requests)
            }
    }
    
    // Keeps check on the bookings and updates at a time 
    func observeOwnerBookings(for userId: String, completion: @escaping ([ScheduleRequest]) -> Void) -> ListenerRegistration {
           let query = db.collection("scheduleRequests").whereField("userId", isEqualTo: userId)
           return query.addSnapshotListener { snapshot, error in
               if let error = error {
                   print("Error fetching bookings: \(error.localizedDescription)")
                   completion([])
                   return
               }
               
               var requests: [ScheduleRequest] = []
               for document in snapshot?.documents ?? [] {
                   var requestData = document.data()
                   requestData["requestId"] = document.documentID  // Include the document ID
                   if let scheduleRequest = ScheduleRequest(from: requestData) {
                       requests.append(scheduleRequest)
                   }
               }
               completion(requests)
           }
       }
   

    /// Update the booking status.
    func updateBookingStatus(requestId: String, newStatus: String, completion: @escaping (Error?) -> Void) {
        db.collection("scheduleRequests").document(requestId).updateData([
            "status": newStatus
        ]) { error in
            completion(error)
        }
    }
    
    /// Format a Firestore Timestamp into a date string.
    func formatDate(timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM" // e.g., "12 Feb"
        return formatter.string(from: date)
    }
    
    /// Accept a request and update statuses accordingly.
    func acceptRequest(caretakerId: String, requestId: String, completion: @escaping (Error?) -> Void) {
        let caretakerRef = db.collection("caretakers").document(caretakerId)
        let requestRef = db.collection("scheduleRequests").document(requestId)
        
        requestRef.updateData(["status": "accepted"]) { error in
            if let error = error {
                completion(error)
                return
            }
            
            caretakerRef.setData(["status": "assigned"], merge: true) { error in
                completion(error)
            }
        }
    }
    
    /// Fetch available caretakers and sort them by a score (experience divided by distance).
    func fetchAvailableCaretakers(completion: @escaping ([(DocumentReference, Caretakers, Double)]) -> Void) {
        db.collection("caretakers").whereField("status", isEqualTo: "available").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching available caretakers: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let caretakers = snapshot?.documents.compactMap { doc -> (DocumentReference, Caretakers, Double)? in
                let data = doc.data()
                guard let caretaker = try? Firestore.Decoder().decode(Caretakers.self, from: data) else { return nil }
                
                let experience = caretaker.experience
                let distance = caretaker.distanceAway
                guard distance > 0 else { return nil }
                
                let score = Double(experience) / distance
                return (doc.reference, caretaker, score)
            }.sorted { $0.2 > $1.2 } ?? []
            
            completion(caretakers)
        }
    }
    
    /// Reject a request and reassign it to another available caretaker.
    func rejectRequest(caretakerId: String, requestId: String, sortedCaretakers: [(DocumentReference, Caretakers, Double)], completion: @escaping (Error?) -> Void) {
        let requestRef = db.collection("scheduleRequests").document(requestId)
        
        requestRef.updateData(["status": "rejected"]) { error in
            if let error = error {
                completion(error)
                return
            }
            
            var remainingCaretakers = sortedCaretakers
            remainingCaretakers.removeFirst()
            
            if let (caretakerRef, nextCaretaker, _) = remainingCaretakers.first {
                requestRef.updateData(["caretakerId": nextCaretaker.caretakerId, "status": "pending"]) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    caretakerRef.updateData([
                        "pendingRequests": FieldValue.arrayUnion([requestId])
                    ]) { error in
                        if let error = error {
                            completion(error)
                        } else {
                            print("Request reassigned to caretaker: \(nextCaretaker.name)")
                            completion(nil)
                        }
                    }
                }
            } else {
                print("No more caretakers available.")
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No caretakers available."]))
            }
        }
    }
    
    // MARK: - Vaccination Functions
    
    func saveVaccinationData(petId: String, vaccination: VaccinationDetails, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "vaccineName": vaccination.vaccineName,
            "vaccineType": vaccination.vaccineType,
            "dateOfVaccination": vaccination.dateOfVaccination,
            "expiryDate": vaccination.expiryDate,
            "nextDueDate": vaccination.nextDueDate
        ]
        
        print("Saving vaccination data to Firestore...")
        db.collection("Pets").document(petId).collection("Vaccinations").addDocument(data: data) { error in
            if let error = error {
                print("Error saving vaccination: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Vaccination saved successfully!")
                completion(nil)
            }
        }
    }
    
    func deleteVaccinationData(petId: String, vaccineId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Pets").document(petId).collection("Vaccinations").document(vaccineId).delete { error in
            if let error = error {
                print("Error deleting vaccination: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Vaccination deleted successfully!")
                completion(nil)
            }
        }
    }
    
    // MARK: - Pet Diet Functions
    
    func savePetDietData(petId: String, diet: PetDietDetails, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "mealType": diet.mealType,
            "foodName": diet.foodName,
            "foodCategory": diet.foodCategory,
            "portionSize": diet.portionSize,
            "feedingFrequency": diet.feedingFrequency,
            "servingTime": diet.servingTime
        ]
        
        print("Saving pet diet data to Firestore...")
        db.collection("Pets").document(petId).collection("PetDiet").addDocument(data: data) { error in
            if let error = error {
                print("Error saving pet diet: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Pet diet saved successfully!")
                completion(nil)
            }
        }
    }
    
    func deletePetDietData(petId: String, dietId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Pets").document(petId).collection("PetDiet").document(dietId).delete { error in
            if let error = error {
                print("Error deleting pet diet: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Pet diet deleted successfully!")
                completion(nil)
            }
        }
    }
    
    // MARK: - Pet Medication Functions
    
    func savePetMedicationData(petId: String, medication: PetMedicationDetails, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "medicineName": medication.medicineName,
            "medicineType": medication.medicineType,
            "purpose": medication.purpose,
            "frequency": medication.frequency,
            "dosage": medication.dosage,
            "startDate": medication.startDate,
            "endDate": medication.endDate
        ]
        
        print("Saving pet medication data to Firestore...")
        db.collection("Pets").document(petId).collection("PetMedication").addDocument(data: data) { error in
            if let error = error {
                print("Error saving pet medication: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Pet medication saved successfully!")
                completion(nil)
            }
        }
    }
    
    func deletePetMedicationData(petId: String, medicationId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Pets").document(petId).collection("PetMedication").document(medicationId).delete { error in
            if let error = error {
                print("Error deleting pet medication: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Pet medication deleted successfully!")
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch Pet Names
    
    func fetchPetNames(completion: @escaping ([String]) -> Void) {
        db.collection("Pets").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching pets: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No pet documents found in Firestore.")
                completion([])
                return
            }
            
            let petNames: [String] = documents.compactMap { doc in
                return doc.data()["petName"] as? String
            }
            
            DispatchQueue.main.async {
                completion(petNames)
            }
        }
    }
}
    
    
    //    func pushSampleData() {
    //        let samplePets = [
    //            PetLiveUpdate(name: "Buzzo", description: "Found near the Community Park SRM.", location: CLLocationCoordinate2D(latitude: 12.8230, longitude: 80.0444), im: ["pick1", "pick2", "pick3"]),
    //            PetLiveUpdate(name: "Fluffy", description: "Spotted near the main gate.", location: CLLocationCoordinate2D(latitude: 12.8210, longitude: 80.0424), im: ["pick1", "pick2", "pick3"]),
    //            PetLiveUpdate(name: "Max", description: "Seen by the sports complex.", location: CLLocationCoordinate2D(latitude: 12.8250, longitude: 80.0454), im: ["pick1", "pick2", "pick3"])
    //            ]
    //
    //            let db = Firestore.firestore()
    //            for pet in samplePets {
    //                db.collection("petsLive").addDocument(data: pet.toDictionary()) { error in
    //                    if let error = error {
    //                        print("Error adding document: \(error)")
    //                    } else {
    //                        print("Document added successfully!")
    //                    }
    //            }
    //        }
    //    }
    
//}








