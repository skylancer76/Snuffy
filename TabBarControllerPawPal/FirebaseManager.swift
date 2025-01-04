//
//  FirebaseManager.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import Foundation
import FirebaseFirestore

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
