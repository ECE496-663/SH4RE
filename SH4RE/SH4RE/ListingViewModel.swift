//
//  ListingViewModel.swift
//  SH4RE
//
//  Created by Bryan Brown on 2022-11-26.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseStorage



//Struct for listing TODO add more properties
struct Listing : Identifiable{
    var id :String =  UUID().uuidString
    var title:String
    var description:String
    var imagepath:String
}

class ListingViewModel : ObservableObject{
    @Published var listings = [Listing]()
    private var db = Firestore.firestore()
    var image:UIImage = UIImage()
    func fetchListings(){
        db.collection("Listings").addSnapshotListener{(QuerySnapshot, Error) in
            guard let listings = QuerySnapshot?.documents else{
                print("No listings found")
                return
            }
            self.listings = listings.map{ (QueryDocumentSnapshot) -> Listing in
                let data = QueryDocumentSnapshot.data()
                
                //Assign listing properties here
                let id = QueryDocumentSnapshot.documentID
                let title = data["Title"] as? String ?? ""
                let description = data["Description"] as? String ?? ""
                let imagepath = data["image_path"] as? String ?? ""
                
//                let storage = Storage.storage()
//                let storageRef = storage.reference().child(image_path)
//
//                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if error != nil {
//                            print("Error: Image could not download!")
//                        } else {
//                            self.image = UIImage(data: data!)!
//                        }
//                    }

                return Listing(id:id, title:title, description:description, imagepath:imagepath)
            }
        }
    }
}
