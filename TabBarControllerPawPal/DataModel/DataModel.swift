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
    var coverImageURL: String?

    var isRecommended: Bool?
    var about: String?
    var galleryImages: [String]?
    var bookings: [Bookings]?

    // Initialization
    init(
        id: UUID = UUID(),
        name: String,
        price: String,
        address: String,
        profileImageName: String,
        rating: String? = nil,
        coverImageURL: String? = nil,
        isRecommended: Bool? = nil,
        about: String? = nil,
        galleryImages: [String]? = nil,
        bookings: [Bookings]? = nil )
    {
        self.id = id
        self.name = name
        self.price = price
        self.address = address
        self.profileImageName = profileImageName
        self.rating = rating
        self.coverImageURL = coverImageURL
        self.isRecommended = isRecommended
        self.about = about
        self.galleryImages = galleryImages
        self.bookings = bookings

    }
}

// MARK: - Booking Model
struct Bookings: Codable {
    var date: String
    var isCompleted: Bool
    var status: String?
    var price: String?
    var image: String
}

//// MARK: - Pet Data Model
//class PetData {
//    var petImage: String
//    var petName: String
//    var petBreed: String
//    var petGender: String
//    var petAge: String?
//    var petWeight: String?
//
//    var healthDetails: HealthDetails?
//    var dietaryDetails: DietaryDetails?
//    var medications: [Medication]?
//    var vaccinationDetails: [VaccinationDetails]?
//
//    init(
//        petImage: String,
//        petName: String,
//        petBreed: String,
//        petGender: String,
//        petAge: String? = nil,
//        petWeight: String? = nil,
//        healthDetails: HealthDetails? = nil,
//        dietaryDetails: DietaryDetails? = nil,
//        medications: [Medication]? = nil,
//        vaccinationDetails: [VaccinationDetails]? = nil
//    ) {
//        self.petImage = petImage
//        self.petName = petName
//        self.petBreed = petBreed
//        self.petGender = petGender
//        self.petAge = petAge
//        self.petWeight = petWeight
//        self.healthDetails = healthDetails
//        self.dietaryDetails = dietaryDetails
//        self.medications = medications
//        self.vaccinationDetails = vaccinationDetails
//    }
//}
//
//// MARK: - Health Details Model
//class HealthDetails {
//    var healthCondition: String?
//    var vetVisitDate: String?
//    var otherNotes: String?
//
//    init(healthCondition: String? = nil, vetVisitDate: String? = nil, otherNotes: String? = nil) {
//        self.healthCondition = healthCondition
//        self.vetVisitDate = vetVisitDate
//        self.otherNotes = otherNotes
//    }
//}
//
//// MARK: - Dietary Details Model
//class DietaryDetails {
//    var foodPreferences: String?
//    var allergies: String?
//    var feedingSchedule: String?
//
//    init(foodPreferences: String? = nil, allergies: String? = nil, feedingSchedule: String? = nil) {
//        self.foodPreferences = foodPreferences
//        self.allergies = allergies
//        self.feedingSchedule = feedingSchedule
//    }
//}
//
//// MARK: - Medication Model
//class Medication {
//    var medicineName: String
//    var dosage: String
//    var frequency: String
//
//    init(medicineName: String, dosage: String, frequency: String) {
//        self.medicineName = medicineName
//        self.dosage = dosage
//        self.frequency = frequency
//    }
//}
//
//// MARK: - Vaccination Details Model
//class VaccinationDetails {
//    var vaccineName: String
//    var vaccineType: String
//    var dateOfVaccination: String
//    var expiryDate: String
//    var nextDueDate: String
//
//    init(
//        vaccineName: String,
//        vaccineType: String,
//        dateOfVaccination: String,
//        expiryDate: String,
//        nextDueDate: String
//    ) {
//        self.vaccineName = vaccineName
//        self.vaccineType = vaccineType
//        self.dateOfVaccination = dateOfVaccination
//        self.expiryDate = expiryDate
//        self.nextDueDate = nextDueDate
//    }
//}
