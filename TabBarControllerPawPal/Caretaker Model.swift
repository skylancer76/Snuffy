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
    PetSitter(name: "Katie", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Profile Image 1", isrecommended: true),
    PetSitter(name: "Katie", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Profile Image 1", isrecommended: false),
    PetSitter(name: "Katie", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Profile Image 1",  isrecommended: true),
    PetSitter(name: "Katie", price: "Rs 350 / Day", distance: "2.7 km, Chennai", rating: "Rating1", isVerified: true, profileImageName: "Profile Image 1", isrecommended: false)
]

struct Booking{
    var name: String
    var date: String
    var iscompleted: Bool
    var image: String
    var status : String?
    
}

var bookings: [Booking] = [
    Booking(name: "Shraddha", date: "03 Jun 24 • 11 Jun 24", iscompleted: true, image: "Shraddha", status: "Completed"),
    Booking(name: "Shraddha", date: "03 Jun 24 • 11 Jun 24", iscompleted: false, image: "Karan", status: "ongoing"),
    Booking(name: "Shraddha", date: "04 May 24 • 09 May 24 ", iscompleted: false, image: "Ananya",status: "pending"),
    Booking(name: "Shraddha", date: "02 Feb 24 • 21 Feb 24", iscompleted: true, image: "Aman",status: "Completed"),
    Booking(name: "Shraddha", date: "13 Dec 23 • 24 Dec 23", iscompleted: true, image: "Pooja",status: "Completed"),
    Booking(name: "Shraddha", date: "19 Nov 23 • 05 Dec 23", iscompleted: true, image: "Shraddha",status: "Completed")
    
]

