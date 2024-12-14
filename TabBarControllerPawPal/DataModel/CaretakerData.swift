//
//  CaretakerData.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 16/11/24.
//

import Foundation

import Foundation

// MARK: - Unified Caretaker Class
//class Caretaker {
//    var id: String                  // Unique identifier (Firebase)
//    var name: String
//    var price: String
//    var address: String
//    var rating: String
//    var isVerified: Bool
//    var profileImageName: String
//    
//    var distance: String?           // Distance from user (optional for search results)
//    var isRecommended: Bool?        // Flag for recommended caretakers
//    var about: String?              // Description for detailed screen
//    var galleryImages: [String]?    // Images for caretaker profile
//    var bookings: [Booking]?        // List of bookings
//    var petData: PetData?           // Pet-specific data
//    
//    init(
//        id: String,
//        name: String,
//        price: String,
//        address: String,
//        rating: String,
//        isVerified: Bool,
//        profileImageName: String,
//        distance: String? = nil,
//        isRecommended: Bool? = nil,
//        about: String? = nil,
//        galleryImages: [String]? = nil,
//        bookings: [Booking]? = nil,
//        petData: PetData? = nil
//    ) {
//        self.id = id
//        self.name = name
//        self.price = price
//        self.address = address
//        self.rating = rating
//        self.isVerified = isVerified
//        self.profileImageName = profileImageName
//        self.distance = distance
//        self.isRecommended = isRecommended
//        self.about = about
//        self.galleryImages = galleryImages
//        self.bookings = bookings
//        self.petData = petData
//    }
//}
//
//// MARK: - Supporting Models
//
//// Booking model
//struct Booking: Codable {
//    var date: String
//    var isCompleted: Bool
//    var status: String?
//    var price: String?
//    var image: String
//}
//
//// Pet-specific data model
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
//// Health details for a pet (e.g., health condition, vet visits)
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
//// Dietary details for a pet (e.g., food preferences, allergies)
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
//// Medications for a pet (e.g., medicine name, dosage)
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
//// Vaccination details for a pet
//class VaccinationDetails {
//var vaccineName: String
//var vaccineType: String
//var dateOfVaccination: String
//var expiryDate: String
//var nextDueDate: String
//
//    init(vaccineName: String, dateOfVaccination: String,vaccineType: String, expiryDate: String,nextDueDate: String  ) {
//        self.vaccineName = vaccineName
//        self.vaccineType = vaccineType
//        self.dateOfVaccination = vaccineDate
//        self.expiryDate = ExpiryDate
//self.nextDueDate = nextDueDate



//    }
//}
