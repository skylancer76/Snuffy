//
//  DataModel.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import Foundation


// MARK: - Unified Caretaker Model
class Caretakers : Codable {
    var id: UUID
    var name: String
    var price: String
    var address: String
    var profileImageName: String
    var rating: String?
    var coverImage: String?
    var distance : String?
    var isRecommended: Bool?
    var about: String?
    var experience : String?
    var petSitted : String?
    var galleryImages: [String]
    var bookings: [Bookings]?

    // Initialization
    init(
        id: UUID = UUID(),
        name: String,
        price: String,
        address: String,
        profileImageName: String,
        rating: String? = nil,
        coverImage: String? = nil,
        distance : String? = nil,
        isRecommended: Bool? = nil,
        experience:String? = nil,
        petSitted : String? = nil,
        about: String? = nil,
        galleryImages: [String],
        bookings: [Bookings]? = nil )
    {
        self.id = id
        self.name = name
        self.price = price
        self.address = address
        self.profileImageName = profileImageName
        self.rating = rating
        self.coverImage = coverImage
        self.isRecommended = isRecommended
        self.about = about
        self.distance = distance
        self.experience = experience
        self.petSitted = petSitted
        self.galleryImages = galleryImages
        self.bookings = bookings

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
class PetData {
    var petId: String  // New unique identifier for each pet
    var petImage: String?
    var petName: String?
    var petBreed: String?
    var petGender: String?
    var petAge: String?
    var petWeight: String?
    var dietaryDetails: DietaryDetails?
    var medications: [Medication]?
    var vaccinationDetails: [VaccinationDetails]?
    
    init(
        petId: String = UUID().uuidString,  // Use UUID to generate unique ID
        petImage: String? = nil,
        petName: String? = nil,
        petBreed: String? = nil,
        petGender: String? = nil,
        petAge: String? = nil,
        petWeight: String? = nil,
        dietaryDetails: DietaryDetails? = nil,
        medications: [Medication]? = nil,
        vaccinationDetails: [VaccinationDetails]? = nil
    ) {
        self.petId = petId
        self.petImage = petImage
        self.petName = petName
        self.petBreed = petBreed
        self.petGender = petGender
        self.petAge = petAge
        self.petWeight = petWeight
        self.dietaryDetails = dietaryDetails
        self.medications = medications
        self.vaccinationDetails = vaccinationDetails
    }
}


// MARK: - Dietary Details Model
class DietaryDetails {
    var foodPreferences: String?
    var allergies: String?
    var feedingSchedule: String?

    init(foodPreferences: String? = nil, allergies: String? = nil, feedingSchedule: String? = nil) {
        self.foodPreferences = foodPreferences
        self.allergies = allergies
        self.feedingSchedule = feedingSchedule
    }
}

// MARK: - Medication Model
class Medication {
    var medicineName: String
    var dosage: String
    var frequency: String

    init(medicineName: String, dosage: String, frequency: String) {
        self.medicineName = medicineName
        self.dosage = dosage
        self.frequency = frequency
    }
}

// MARK: - Vaccination Details Model
class VaccinationDetails {
    var vaccineName: String
    var vaccineType: String
    var dateOfVaccination: String
    var expiryDate: String
    var nextDueDate: String

    init(
        vaccineName: String,
        vaccineType: String,
        dateOfVaccination: String,
        expiryDate: String,
        nextDueDate: String
    ) {
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


