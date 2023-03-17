//
//  FavouritesModel.swift
//  SH4RE
//
//  Created by Americo on 2023-03-17.
//

import SwiftUI

class FavouritesModel: ObservableObject {
    @Published var favourites:Set<String> = []
    
    func addFavourite(listingID:String){
        favourites.insert(listingID)
    }
    
    func removeFavourite(listingID:String) {
        favourites.remove(listingID)
    }
    
    /// Returns the updated state of whether or not the listing is favourited
    func toggleFavourite(listingID:String) -> Bool {
        if(favourites.contains(listingID)){
            favourites.remove(listingID)
            return false
        } else {
            favourites.insert(listingID)
            return true
        }
    }
    
    func isFavourited(listingID:String) -> Bool {
        return favourites.contains(listingID)
    }
}
