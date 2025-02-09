//
//  DataModel.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import Foundation
import CoreLocation
import FirebaseCore
import FirebaseFirestore

// MARK: - Unified Caretaker Model
class Caretakers: Codable {
    var caretakerId: String
    var name: String
    var email: String
    var password: String
    var profilePic: String
    var bio: String
    var experience: Int
    var address: String
    var location: [Double] // [latitude, longitude]
    var distanceAway: Double
    var status: String
    var pendingRequests: [String] // List of pending request IDs
    var completedRequests: Int
    var phoneNumber: String?
    var latitude: Double? {
            return location.count > 0 ? location[0] : nil
        }
        
    var longitude: Double? {
            return location.count > 1 ? location[1] : nil
        }
    // Initialization
    init(
        caretakerId: String,
        name: String,
        email: String,
        password: String,
        profilePic: String,
        bio: String,
        experience: Int,
        address: String,
        location: [Double],
        distanceAway: Double = 0.0,
        status: String = "available",
        pendingRequests: [String] = [],
        completedRequests: Int = 0,
        phoneNumber: String? = nil
    ) {
        self.caretakerId = caretakerId
        self.name = name
        self.email = email
        self.password = password
        self.profilePic = profilePic
        self.bio = bio
        self.experience = experience
        self.address = address
        self.location = location
        self.distanceAway = distanceAway
        self.status = status
        self.pendingRequests = pendingRequests
        self.completedRequests = completedRequests
        self.phoneNumber = phoneNumber
    }
}

// MARK: - Booking Model
//struct Bookings: Codable {
//    var name : String
//    var date: String
//    var isCompleted: Bool
//    var status: String?
//    var price: String?
//    var image: String
//}

// MARK: - Pet Data Model
class PetData: Codable {
    var petId: String
    var petImage: String?
    var petName: String?
    var petBreed: String?
    var petGender: String?
    var petAge: String?
    var petWeight: String?
    var medications: [PetMedicationDetails]?
    var vaccinationDetails: [VaccinationDetails]?
    var dietaryDetails: [PetDietDetails]?
    
    init(
        petId: String = UUID().uuidString,
        petImage: String? = nil,
        petName: String? = nil,
        petBreed: String? = nil,
        petGender: String? = nil,
        petAge: String? = nil,
        petWeight: String? = nil,
        medications: [PetMedicationDetails]? = nil,
        vaccinationDetails: [VaccinationDetails]? = nil,
        dietaryDetails: [PetDietDetails]? = nil

    ) {
        self.petId = petId
        self.petImage = petImage
        self.petName = petName
        self.petBreed = petBreed
        self.petGender = petGender
        self.petAge = petAge
        self.petWeight = petWeight
        self.medications = medications
        self.vaccinationDetails = vaccinationDetails
        self.dietaryDetails = dietaryDetails
    }
}

// MARK: - Dietary Details Model
class PetDietDetails: Codable {
    
    var dietId: String?
    var mealType: String
    var foodName: String
    var foodCategory: String
    var portionSize: String
    var feedingFrequency: String
    var servingTime: String

    init(
        dietId: String? = nil,
        mealType: String,
        foodName: String,
        foodCategory: String,
        portionSize: String,
        feedingFrequency: String,
        servingTime: String
    ) {
        self.dietId = dietId
        self.mealType = mealType
        self.foodName = foodName
        self.foodCategory = foodCategory
        self.portionSize = portionSize
        self.feedingFrequency = feedingFrequency
        self.servingTime = servingTime
    }
}


// MARK: - Medication Model
class PetMedicationDetails: Codable {
    
    var medicationId: String?
    var medicineName: String
    var medicineType: String
    var purpose: String
    var frequency: String
    var dosage: String
    var startDate: String
    var endDate: String

    init(
        medicationId: String? = nil,
        medicineName: String,
        medicineType: String,
        purpose: String,
        frequency: String,
        dosage: String,
        startDate: String,
        endDate: String
    ) {
        self.medicationId = medicationId
        self.medicineName = medicineName
        self.medicineType = medicineType
        self.purpose = purpose
        self.frequency = frequency
        self.dosage = dosage
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Vaccination Details Model
class VaccinationDetails: Codable {
    
    var vaccineId: String?
    var vaccineName: String
    var vaccineType: String
    var dateOfVaccination: String
    var expiryDate: String
    var nextDueDate: String

    init(
        vaccineId: String? = nil,
        vaccineName: String,
        vaccineType: String,
        dateOfVaccination: String,
        expiryDate: String,
        nextDueDate: String
    ) {
        self.vaccineId = vaccineId
        self.vaccineName = vaccineName
        self.vaccineType = vaccineType
        self.dateOfVaccination = dateOfVaccination
        self.expiryDate = expiryDate
        self.nextDueDate = nextDueDate
    }
}





struct ScheduleCaretakerRequest: Codable {
    
    // MARK: - Required Fields
    var requestId: String
    var userId: String
    var userName: String
    var petName: String
    var startDate: Date
    var endDate: Date
    var petPickup: Bool
    var petDropoff: Bool
    var instructions: String
    var status: String
    var caretakerId: String
    var petId: String?
    var petImageUrl: String?
    var petBreed: String?
    var buildingNo: String?
    var houseNo: String?
    var landmark: String?
    var location: String?
    var latitude: Double?
    var longitude: Double?
    var duration: String
    var timestamp: Date? // If you want to store the Firestore "timestamp" field
    
    init?(from data: [String: Any]) {
       
        guard let requestId = data["requestId"] as? String,
              let userId    = data["userId"] as? String,
              let userName  = data["userName"] as? String,
              let petName   = data["petName"]  as? String,
              let startTimestamp = data["startDate"] as? Timestamp,
              let endTimestamp = data["endDate"] as? Timestamp,
              let petPickup   = data["petPickup"] as? Bool,
              let petDropoff  = data["petDropoff"] as? Bool,
              let instructions = data["instructions"] as? String,
              let caretakerId = data["caretakerId"] as? String,
              let status      = data["status"] as? String
        else {
            return nil
        }
        
        self.requestId = requestId
        self.userId = userId
        self.userName = userName
        self.petName = petName
        self.startDate = startTimestamp.dateValue()
        self.endDate = endTimestamp.dateValue()
        self.petPickup = petPickup
        self.petDropoff = petDropoff
        self.instructions = instructions
        self.caretakerId = caretakerId
        self.status = status
        self.petId  = data["petId"]        as? String
        self.petImageUrl = data["petImageUrl"]  as? String
        self.petBreed = data["petBreed"]     as? String
        self.buildingNo = data["buildingNo"]   as? String
        self.houseNo = data["houseNo"]      as? String
        self.landmark = data["landmark"]     as? String
        self.location = data["location"]     as? String
        self.latitude = data["latitude"]     as? Double
        self.longitude = data["longitude"]    as? Double
        self.duration = ScheduleCaretakerRequest.formatDateRange(start: startTimestamp,
                                                            end: endTimestamp)
        if let rawTimestamp = data["timestamp"] as? Timestamp {
            self.timestamp = rawTimestamp.dateValue()
        } else {
            self.timestamp = nil
        }
    }
    
    static func formatDateRange(start: Timestamp, end: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let startStr = dateFormatter.string(from: start.dateValue())
        let endStr   = dateFormatter.string(from: end.dateValue())
        return "\(startStr) - \(endStr)"
    }
}

struct ChatMessage {
    var senderId: String
    var text: String
    var timestamp: Date
}

class PetLiveUpdate  {
    var name: String
    var description: String
    var location: CLLocationCoordinate2D
    var im: [String]
    
    init(name: String, description: String, location: CLLocationCoordinate2D, im: [String]) {
        self.name = name
        self.description = description
        self.location = location
        self.im = im
    }
    
    // Convert to Dictionary
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "description": description,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "im": im
        ]
    }
    
    // Initialize from Dictionary
    convenience init?(from dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let description = dictionary["description"] as? String,
              let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double,
              let im = dictionary["im"] as? [String] else {
            print("Failed to decode PetLiveUpdate from dictionary: \(dictionary)")
            return nil
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.init(name: name, description: description, location: location, im: im)
    }
}


