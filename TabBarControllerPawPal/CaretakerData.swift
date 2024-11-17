//
//  CaretakerData.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 16/11/24.
//

import Foundation

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
