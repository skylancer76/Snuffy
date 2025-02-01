//
//  FirebaseManager.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // Save pet data to Firestore with unique petId
    func savePetDataToFirebase(data: [String: Any], petId: String, completion: @escaping (Error?) -> Void) {
        let collection = db.collection("Pets")
        
        // Use the petId as the document ID for this pet
        collection.document(petId).setData(data) { error in
            if let error = error {
                print("Failed to save pet data: \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // Save caretaker data to Firestore
    func saveCaretakerData(caretakers: [Caretakers], completion: @escaping (Error?) -> Void) {
        let collection = db.collection("Caretakers")
        
        for caretaker in caretakers {
            do {
                let data = try Firestore.Encoder().encode(caretaker)
                collection.document(caretaker.id.uuidString).setData(data) { error in
                    if let error = error {
                        print("Failed to save caretaker: \(error.localizedDescription)")
                    }
                }
            } catch {
                completion(error)
            }
        }
        completion(nil)
    }
    
    
    // Save schedule request data to Firestore
    func saveScheduleRequestData(data: [String: Any], completion: @escaping (Error?) -> Void) {
        let collection = db.collection("scheduleRequests")
        
        // Add a new document to the "scheduleRequests" collection
        collection.addDocument(data: data) { error in
            if let error = error {
                print("Failed to save schedule request: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Schedule request successfully saved!")
                completion(nil)
            }
        }
    }
    
    // save vaccination data
    func saveVaccinationData(petId: String, vaccination: VaccinationDetails, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "vaccineName": vaccination.vaccineName,
            "vaccineType": vaccination.vaccineType,
            "dateOfVaccination": vaccination.dateOfVaccination,
            "expiryDate": vaccination.expiryDate,
            "nextDueDate": vaccination.nextDueDate,
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
    
    
    // Fetch pets from Firestore
    func fetchPets(completion: @escaping ([PetLiveUpdate]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("petsLive").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var pets: [PetLiveUpdate] = []
            for document in querySnapshot?.documents ?? [] {
                if let pet = PetLiveUpdate(from: document.data()) {
                    pets.append(pet)
                } else {
                    print("Failed to initialize PetLiveUpdate from document: \(document.data())")
                }
            }
            completion(pets)
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
    
}








