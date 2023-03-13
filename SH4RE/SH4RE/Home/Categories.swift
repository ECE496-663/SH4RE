//
//  CategoriesClass.swift
//  SH4RE
//
//  Created by Americo on 2023-03-13.
//

import SwiftUI

struct Category: Identifiable {
    var name: String
    var image: UIImage
    //  Create a unique ID for our object
    //  This idea allows Category to conform to Identifiable
    let id = UUID()
}

func getCategoriesAndImg() -> [Category] {
    return [Category(name:"Film & Photography", image:UIImage(named: "filmPhotography")!),
            Category(name:"Audio Visual Equipment", image:UIImage(named: "avEquipement")!),
            Category(name:"Projectors & Screens", image:UIImage(named: "projectorsScreens")!),
            Category(name:"Drones", image:UIImage(named: "drones")!),
            Category(name:"DJ Equipment", image:UIImage(named: "djEquipment")!),
            Category(name:"Transport", image:UIImage(named: "transport")!),
            Category(name:"Storage", image:UIImage(named: "storage")!),
            Category(name:"Electronics", image:UIImage(named: "electronics")!),
            Category(name:"Party & Events", image:UIImage(named: "party")!),
            Category(name:"Sports", image:UIImage(named: "sports")!),
            Category(name:"Musical Instruments", image:UIImage(named: "instruments")!),
            Category(name:"Home, Office & Garden", image:UIImage(named: "homeOfficeGarden")!),
            Category(name:"Holiday & Travel", image:UIImage(named: "holidayTravel")!),
            Category(name:"Clothing", image:UIImage(named: "clothing")!)
    ]
}
