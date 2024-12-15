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
    var distance : String?
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
        distance : String? = nil,
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
        self.distance = distance
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

let caretakers: [Caretakers] = []
//    Caretakers(
//        name: "Katie",
//        price: "Price: Rs 350 / Day",
//        address: "2.7 km, Chennai",
//        profileImageName: "Profile Image 1",
//        rating: "4.5",
//        coverImageURL: "background image",
//        distance: "2.7 km",
//        isRecommended: true,
//        about: "Loving and caring caretaker with 5 years of experience in pet sitting.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "03 Jun 24 • 11 Jun 24", isCompleted: true, status: "Completed", price: "Rs 350 / Day", image: "Profile Image 1")
//        ]
//    ),
//    Caretakers(
//        name: "Ananya",
//        price: "Price: Rs 250 / Day",
//        address: "3 km, Chennai",
//        profileImageName: "Ananya",
//        rating: "4.7",
//        coverImageURL: "background image",
//        distance: "3 km",
//        isRecommended: true,
//        about: "Friendly and experienced with both cats and dogs, ensuring safe and fun care.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "04 May 24 • 09 May 24", isCompleted: false, status: "Pending", price: "Rs 250 / Day", image: "Ananya")
//        ]
//    ),
//    Caretakers(
//        name: "Karan",
//        price: "Price: Rs 300 / Day",
//        address: "3.2 km, Chennai",
//        profileImageName: "Karan",
//        rating: "4.3",
//        coverImageURL: "background image",
//        distance: "3.2 km",
//        isRecommended: false,
//        about: "Specializes in caring for large dogs with active needs.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "03 Jun 24 • 11 Jun 24", isCompleted: false, status: "Ongoing", price: "Rs 300 / Day", image: "Karan")
//        ]
//    ),
//    Caretakers(
//        name: "Pooja",
//        price: "Price: Rs 350 / Day",
//        address: "2.7 km, Chennai",
//        profileImageName: "Pooja",
//        rating: "4.8",
//        coverImageURL: "background image",
//        distance: "2.7 km",
//        isRecommended: true,
//        about: "Offers a clean and playful environment with regular updates to owners.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "13 Dec 23 • 24 Dec 23", isCompleted: true, status: "Completed", price: "Rs 350 / Day", image: "Pooja")
//        ]
//    ),
//    Caretakers(
//        name: "Aman",
//        price: "Price: Rs 250 / Day",
//        address: "4 km, Chennai",
//        profileImageName: "Aman",
//        rating: "4.2",
//        coverImageURL: "https://example.com/images/aman_cover.jpg",
//        distance: "4 km",
//        isRecommended: false,
//        about: "Reliable caretaker with experience in administering medications to pets.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "02 Feb 24 • 21 Feb 24", isCompleted: true, status: "Completed", price: "Rs 250 / Day", image: "Aman")
//        ]
//    ),
//    Caretakers(
//        name: "Shraddha",
//        price: "Price: Rs 400 / Day",
//        address: "5 km, Chennai",
//        profileImageName: "Shraddha",
//        rating: "4.9",
//        coverImageURL: "background image",
//        distance: "5 km",
//        isRecommended: true,
//        about: "Trusted sitter known for her patience and love for all pets.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "19 Nov 23 • 05 Dec 23", isCompleted: true, status: "Completed", price: "Rs 400 / Day", image: "Shraddha")
//        ]
//    ),
//    Caretakers(
//        name: "Nidhi",
//        price: "Price: Rs 400 / Day",
//        address: "4.5 km, Chennai",
//        profileImageName: "Profile Image 1",
//        rating: "4.6",
//        coverImageURL: "background image",
//        distance: "4.5 km",
//        isRecommended: false,
//        about: "Experienced with high-energy pets and ensuring daily exercise needs.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(date: "19 Nov 23 • 05 Dec 23", isCompleted: true, status: "Completed", price: "Rs 400 / Day", image: "Profile Image 1")
//        ]
//    )
//]


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
