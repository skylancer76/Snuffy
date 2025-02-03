//
//  DataModel.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import Foundation

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
        completedRequests: Int = 0
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
    }
}

// MARK: - Booking Model
struct Bookings: Codable {
    var name : String
    var date: String
    var isCompleted: Bool
    var status: String?
    var price: String?
    var image: String
}

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




import CoreLocation

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


