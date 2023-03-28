//
//  FavouritesModel.swift
//  SH4RE
//
//  Created by Americo on 2023-03-17.
//

import SwiftUI

class FavouritesModel: ObservableObject {
    //TODO: Bryan - grab favourites from server and reset this
    @Published var favourites:Set<String> = []
    
    func addFavourite(listingID:String){
        //TODO: Bryan - push to favourites table in firebase here
        favourites.insert(listingID)
    }
    
    func removeFavourite(listingID:String) {
        //TODO: Bryan - remove form favourites table in firebase here
        favourites.remove(listingID)
    }
    
    /// Returns the updated state of whether or not the listing is favourited
    func toggleFavourite(listingID:String) -> Bool {
        if(isFavourited(listingID:listingID)){
            removeFavourite(listingID:listingID)
            return false
        } else {
            addFavourite(listingID: listingID)
            return true
        }
    }
    
    func isFavourited(listingID:String) -> Bool {
        return favourites.contains(listingID)
    }
}
