//
//  petData.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 16/11/24.
//

import Foundation

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
