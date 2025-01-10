//
//  FirebaseManager.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation
class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    // Save caretaker data to Firestore
    func saveCaretakerData(caretakers: [Caretakers], completion: @escaping (Error?) -> Void) {
        let collection = db.collection("Caretakers")
        
        for caretaker in caretakers {
            do {
                // Convert Caretakers to dictionary
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
    
 
        func savePetDataToFirebase(data: [String: Any], completion: @escaping (Error?) -> Void) {
            let collection = db.collection("Pets")
            collection.addDocument(data: data) { error in
                if let error = error {
                    print("Failed to save pet data: \(error.localizedDescription)")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    func pushSampleData() {
            let samplePets = [
                PetLiveUpdate(name: "Buzzo", description: "Found near the Community Park SRM.", location: CLLocationCoordinate2D(latitude: 12.8230, longitude: 80.0444), im: ["pick1", "pick2", "pick3"]),
                PetLiveUpdate(name: "Fluffy", description: "Spotted near the main gate.", location: CLLocationCoordinate2D(latitude: 12.8210, longitude: 80.0424), im: ["pick1", "pick2", "pick3"]),
                PetLiveUpdate(name: "Max", description: "Seen by the sports complex.", location: CLLocationCoordinate2D(latitude: 12.8250, longitude: 80.0454), im: ["pick1", "pick2", "pick3"])
            ]
            
            let db = Firestore.firestore()
            for pet in samplePets {
                db.collection("petsLive").addDocument(data: pet.toDictionary()) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully!")
                    }
                }
            }
        }
    }


extension FirebaseManager {
    func fetchCaretakerData(completion: @escaping ([Caretakers]?, Error?) -> Void) {
        let collection = db.collection("Caretakers")
        collection.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(nil, nil)
                return
            }

            let caretakers = documents.compactMap { document -> Caretakers? in
                do {
                    return try document.data(as: Caretakers.self)
                } catch {
                    print("Error decoding caretaker: \(error.localizedDescription)")
                    return nil
                }
            }
            completion(caretakers, nil)
        }
    }
}


extension FirebaseManager {
    func fetchCaretakerProfile(name: String, completion: @escaping (Caretakers?, Error?) -> Void) {
        let collection = db.collection("Caretakers")
        collection.whereField("name", isEqualTo: name).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(nil, nil)
                return
            }

            do {
                let caretaker = try document.data(as: Caretakers.self)
                completion(caretaker, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

extension FirebaseManager {
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
            print("Fetched pets: \(pets)") // Log fetched pets
            completion(pets)
        }
    }
}
extension UIImageView {
    func loadImageFromUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
