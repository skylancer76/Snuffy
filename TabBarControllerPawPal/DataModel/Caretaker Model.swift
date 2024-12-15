//
//  Caretaker Model.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/11/24.
//

import Foundation

struct Caretaker {
    let name: String
    let title: String
    let ratings: Int
    let experience: String
    let rate: String
    let verified: Bool
//    let location: String
    let about: String
    let galleryImages: [String]
}

struct PetCaretakerInfo {
    let name: String
    let address: String
    let price: String
    let rating: String
    let verified: Bool
    let profileImageName: String
    let petName: String
}


struct PetSitter {
    let name: String
    let price: String
    let distance: String
    let rating: String
    let isVerified: Bool
    let profileImageName: String
    
    var isrecommended : Bool?
}

let petSitters: [PetSitter] = [
    PetSitter(name: "Katie", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true , profileImageName: "Profile Image 1", isrecommended: false),
    PetSitter(name: "Ananya", price: "Rs 250 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Ananya", isrecommended: true),
    PetSitter(name: "Aman", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Aman", isrecommended: false),
    PetSitter(name: "Pooja", price: "Rs 450 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Pooja",  isrecommended: true),
    PetSitter(name: "Shraddha", price: "Rs 250 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Shraddha", isrecommended: false)
]

struct Booking{
    var name: String
    var date: String
    var iscompleted: Bool
    var image: String
    var status : String?
    var price : String?
    
}

var bookings: [Booking] = [
    Booking(name: "Shraddha", date: "03 Jun 24 • 11 Jun 24", iscompleted: true, image: "Shraddha", status: "Completed"),
    Booking(name: "Karan", date: "03 Jun 24 • 11 Jun 24", iscompleted: false, image: "Karan", status: "ongoing"),
    Booking(name: "Ananya", date: "04 May 24 • 09 May 24 ", iscompleted: false, image: "Ananya",status: "pending"),
    Booking(name: "Aman", date: "02 Feb 24 • 21 Feb 24", iscompleted: true, image: "Aman",status: "Completed"),
    Booking(name: "Pooja", date: "13 Dec 23 • 24 Dec 23", iscompleted: true, image: "Pooja",status: "Completed"),
    Booking(name: "Shraddha", date: "19 Nov 23 • 05 Dec 23", iscompleted: true, image: "Shraddha",status: "Completed")
    
]

struct Vaccination : Codable {
    var vaccineName: String
    var vaccineType: String
    var dateOfVaccination: String
    var expiryDate: String
    var nextDueDate: String
}

var vaccinations: [Vaccination] = []


class PetData

{
    var petImage: String
    var petName: String
    var petBreed: String
    var petGender: String
    var petAge: String?
    var petWeight : String?
    
    init(petImage: String, petName: String, petBreed: String, petGender: String, petAge: String , petWeight : String) {
        self.petImage = petImage
        self.petName = petName
        self.petBreed = petBreed
        self.petGender = petGender
        self.petAge  = petAge
        self.petWeight = petWeight
    }
}

struct VaccinationDetails {
    var vacinationName: String
    var vacinationDate: String
    var vacinationDescription: String
    var isVaccinationCompleted: Bool
}

var vaccinationDetails: [VaccinationDetails] = [
    VaccinationDetails(vacinationName: "Rabies", vacinationDate: "16 Jul, 2024", vacinationDescription: "All Doses Completed", isVaccinationCompleted: true),
    VaccinationDetails(vacinationName: "Distemper Vaccine", vacinationDate: "18 Jul, 2024", vacinationDescription: "Booster Dose Needed", isVaccinationCompleted: false),
    VaccinationDetails(vacinationName: "Parvovirus Vaccine", vacinationDate: "20 Jul, 2024", vacinationDescription: "All Doses Completed", isVaccinationCompleted: true),
]

class CaretakerData
{
   
    var name: String
    var price: String
    var address: String
    var rating: String
    var isverified: Bool
    var caretakerImage: String
    
    init(name: String, price: String, address: String, rating: String, isverified: Bool, caretakerImage: String)
    {
        self.name = name
        self.price = price
        self.address = address
        self.rating = rating
        self.isverified = isverified
        self.caretakerImage = caretakerImage
    }
    
}

//import Foundation
//
//// MARK: - Unified Caretaker Model
//class Caretaker {
//    var id: UUID
//    var name: String
//    var price: String
//    var address: String
//    var rating: String
//    var isVerified: Bool
//    var profileImageName: String
//    var coverImageURL: String?
//
//    var distance: String?
//    var isRecommended: Bool?
//    var about: String?
//    var galleryImages: [String]?
//    var bookings: [Bookings]?

//    // Initialization
//    init(
//        id: UUID = UUID(),
//        name: String,
//        price: String,
//        address: String,
//        rating: String,
//        isVerified: Bool,
//        profileImageName: String,
//        coverImageURL: String? = nil,
//        distance: String? = nil,
//        isRecommended: Bool? = nil,
//        about: String? = nil,
//        galleryImages: [String]? = nil,
//        bookings: [Bookings]? = nil )
//    {
//        self.id = id
//        self.name = name
//        self.price = price
//        self.address = address
//        self.rating = rating
//        self.isVerified = isVerified
//        self.profileImageName = profileImageName
//        self.coverImageURL = coverImageURL
//        self.distance = distance
//        self.isRecommended = isRecommended
//        self.about = about
//        self.galleryImages = galleryImages
//        self.bookings = bookings
//
//    }
//}
//
//// MARK: - Booking Model
//struct Bookings: Codable {
//    var date: String
//    var isCompleted: Bool
//    var status: String?
//    var price: String?
//    var image: String
//}

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
