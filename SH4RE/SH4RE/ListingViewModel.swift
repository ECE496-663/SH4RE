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
    var imagepath = [String]()
    var price:String
    var imageDict = UIImage()
}

class ListingViewModel : ObservableObject{
    @Published var listings = [Listing]()
    @Published var image_dict : [String: UIImage] = [:]
    private var db = Firestore.firestore()
    var image:UIImage = UIImage()
    func fetchListings(completion: @escaping (Bool) -> Void){
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
                let imagepath = data["image_path"] as? [String] ?? []
                let price = data["Price"] as? String ?? ""
                return Listing(id:id, title:title, description:description, imagepath:imagepath, price:price)
            }
            if QuerySnapshot!.isEmpty{
                completion(false)
            }else{
                completion(true)
            }
        }
        
    }
    public func fetchProductMainImage(completion: @escaping (Bool) -> Void) {
        
        //Clear Image Array:
        image_dict.removeAll()

        //Access to Image inside a Collection:
        for listing in self.listings{
            
            if(listing.imagepath != []){
                let storageRef = Storage.storage().reference(withPath: listing.imagepath[0])
                
                //Download in Memory with a Maximum Size of 1MB (1 * 1024 * 1024 Bytes):
                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                    
                    if let error = error {
                        //Error:
                        print (error)
                        
                    } else {
                        
                        //Image Returned Successfully:
                        let image = UIImage(data: data!)
                        
                        //Add Images to the Array:
                        self.image_dict[listing.id] = image
                        
                        
                        if(self.image_dict.count == listings.count){
                            completion (true)
                        }
                    }
                }
            }
        }
    }
    
    
}
