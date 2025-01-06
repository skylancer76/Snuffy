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

let caretakers: [Caretakers] = []
//    Caretakers(
//        name: "Katie",
//        price: "Rs 350/Day",
//        address: "2.7 km, Chennai",
//        profileImageName: "Profile Image 1",
//        rating: "4.5",
//        coverImage: "background image",
//        distance: "2.7 km",
//        isRecommended: true,
//        experience: "8 years",
//        petSitted: "15+",
//        about: "Loving and caring caretaker with 5 years of experience in pet sitting.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Katie",date: "03 Jun 24 • 11 Jun 24", isCompleted: true, status: "Completed", price: "Rs 350 / Day", image: "Profile Image 1")
//        ]
//    ),
//    Caretakers(
//        name: "Ananya",
//        price: "Price: Rs 250 / Day",
//        address: "3 km, Chennai",
//        profileImageName: "Ananya",
//        rating: "4.7",
//        coverImage: "background image",
//        distance: "3 km",
//        isRecommended: true,
//        experience: "6 years",
//        petSitted: "10+",
//        about: "Friendly and experienced with both cats and dogs, ensuring safe and fun care.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Ananya",date: "04 May 24 • 09 May 24", isCompleted: false, status: "Pending", price: "Rs 250 / Day", image: "Ananya")
//        ]
//    ),
//    Caretakers(
//        name: "Karan",
//        price: "Price: Rs 300 / Day",
//        address: "3.2 km, Chennai",
//        profileImageName: "Karan",
//        rating: "4.3",
//        coverImage: "background image",
//        distance: "3.2 km",
//        isRecommended: false,
//        experience: "2 years",
//        petSitted: "5",
//        about: "Specializes in caring for large dogs with active needs.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Karan",date: "03 Jun 24 • 11 Jun 24", isCompleted: false, status: "Ongoing", price: "Rs 300 / Day", image: "Karan")
//        ]
//    ),
//    Caretakers(
//        name: "Pooja",
//        price: "Price: Rs 350 / Day",
//        address: "2.7 km, Chennai",
//        profileImageName: "Pooja",
//        rating: "4.8",
//        coverImage: "background image",
//        distance: "2.7 km",
//        isRecommended: true,
//        experience: "1 years",
//        petSitted: "2",
//        about: "Offers a clean and playful environment with regular updates to owners.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Karan",date: "13 Dec 23 • 24 Dec 23", isCompleted: true, status: "Completed", price: "Rs 350 / Day", image: "Pooja")
//        ]
//    ),
//    Caretakers(
//        name: "Aman",
//        price: "Price: Rs 250 / Day",
//        address: "4 km, Chennai",
//        profileImageName: "Aman",
//        rating: "4.2",
//        coverImage: "background image",
//        distance: "4 km",
//        isRecommended: false,
//        experience: "10 years",
//        petSitted: "15+",
//        about: "Reliable caretaker with experience in administering medications to pets.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Aman",date: "02 Feb 24 • 21 Feb 24", isCompleted: true, status: "Completed", price: "Rs 250 / Day", image: "Aman")
//        ]
//    ),
//    Caretakers(
//        name: "Shraddha",
//        price: "Price: Rs 400 / Day",
//        address: "5 km, Chennai",
//        profileImageName: "Shraddha",
//        rating: "4.9",
//        coverImage: "background image",
//        distance: "5 km",
//        isRecommended: true,
//        experience: "4 years",
//        petSitted: "12",
//        about: "Trusted sitter known for her patience and love for all pets.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Shraddha",date: "19 Nov 23 • 05 Dec 23", isCompleted: true, status: "Completed", price: "Rs 400 / Day", image: "Shraddha")
//        ]
//    ),
//    Caretakers(
//        name: "Nidhi",
//        price: "Price: Rs 400 / Day",
//        address: "4.5 km, Chennai",
//        profileImageName: "Profile Image 1",
//        rating: "4.6",
//        coverImage: "background image",
//        distance: "4.5 km",
//        isRecommended: false,
//        experience: "2 years",
//        petSitted: "3s",
//        about: "Experienced with high-energy pets and ensuring daily exercise needs.",
//        galleryImages: ["caretaker1","caretaker2","caretaker3","caretaker4"],
//        bookings: [
//            Bookings(name: "Nidhi",date: "19 Nov 23 • 05 Dec 23", isCompleted: true, status: "Completed", price: "Rs 400 / Day", image: "Profile Image 1")
//        ]
//    )
//]


// MARK: - Pet Data Model
class PetData {
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


