//
//  Deal.swift
//  Drinks
//
//  Created by Ryan Fritsch on 6/13/15.
//  Copyright (c) 2015 Ryan Fritsch. All rights reserved.
//

import Foundation

import UIKit

class Deal: NSObject {
    var name: String
    var price: Double
    var priceString: String
    var notes: String
    var locat: String
    var score: Int
    var long: Double
    var lat: Double
    var image: UIImage
    var id: String
    
    init(name: String, price: Double, notes: String, locat: String, latitude: Double, longitude: Double, score: Int, image: UIImage, id: String) {
        self.name = name
        self.price = price
        self.priceString = String(format: "%.2f", arguments: [price])
        self.notes = notes
        self.score = score
        self.locat = locat
        self.lat = latitude
        self.long = longitude
        self.image = image
        self.id = id
        super.init()
    }
}
