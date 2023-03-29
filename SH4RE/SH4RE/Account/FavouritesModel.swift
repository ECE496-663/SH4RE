//
//  FavouritesModel.swift
//  SH4RE
//
//  Created by Americo on 2023-03-17.
//

import SwiftUI
import Firebase
import FirebaseAuth

class FavouritesModel: ObservableObject {
    @Published var favourites:Set<String> = []
    
    init(){
        if(Auth.auth().currentUser != nil){
            Firestore.firestore().collection("User Info").document(getCurrentUserUid()).collection("Favourites").getDocuments() {(snapshot, error) in
                snapshot?.documents.forEach({ (document) in
                    let data = document.data()
                    let id = document.documentID
                    self.favourites.insert(id)
                })
            }
        }
    }
    
    func addFavourite(listingID:String){
        print(getCurrentUserUid())
        Firestore.firestore().collection("User Info").document(getCurrentUserUid()).collection("Favourites").document(listingID).setData(["exists":true])
        favourites.insert(listingID)
    }
    
    func removeFavourite(listingID:String) {
        Firestore.firestore().collection("User Info").document(getCurrentUserUid()).collection("Favourites").document(listingID).delete()
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
