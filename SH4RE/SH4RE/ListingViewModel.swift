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
    var uid : String
    var title:String
    var description:String
    var imagepath = [String]()
    var price:String
    var imageDict = UIImage()
    var availability = [(Date,Date)]()
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
                let uid = data["uid"] as? String ?? ""
                let title = data["Title"] as? String ?? ""
                let description = data["Description"] as? String ?? ""
                let imagepath = data["image_path"] as? [String] ?? []
                let price = data["Price"] as? String ?? ""
                let timestampAvailability = data["Availability"] as? [Timestamp] ?? []
                var availability = [(Date,Date)]()
                for i in Swift.stride(from: 0, to: timestampAvailability.count, by: 2) {
                    let start = timestampAvailability[i].dateValue()
                    let end = timestampAvailability[i+1].dateValue()
                    let booked = (start, end)
                    availability.append(booked)
                }
                return Listing(id:id,uid:uid, title:title, description:description, imagepath:imagepath, price:price, availability: availability)
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

func bookListing(listing_id : String, start: Date, end: Date){
    let db = Firestore.firestore()
    db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayUnion([Timestamp(date: start)])
    ])
    db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayUnion([Timestamp(date: end)])
    ])
}

func unbookListing(listing_id : String, start: Date, end: Date){
    let db = Firestore.firestore()
    db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayRemove([Timestamp(date: start)])
    ])
    db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayRemove([Timestamp(date: end)])
    ])
}

func sendBookingRequest(uid: String, listing_id : String, start: Date, end: Date){
    let collectionRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests")
    
    collectionRef.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            if (querySnapshot!.isEmpty){
                let startTime = Timestamp(date:start)
                let endTime = Timestamp(date:end)
                collectionRef.document().setData(["uid":uid, "start" : startTime, "end":endTime, "status" : "pending" ])
                bookListing(listing_id: listing_id, start: start, end: end)
                
                //add to messages
                
            }else{
                //Add something to return to front end
                //probably 0 is success and else a failure code
                print("booking request already made")
            }
        }
    }
}

func acceptRentalRequest(listing_id: String, rental_request_id : String){
    let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)
    docRef.updateData(["status": "accepted"])
    //send accept message
}

func denyRentalRequest(listing_id: String, rental_request_id : String){
    let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)
    
    docRef.updateData(["status": "denied"])
    
    docRef.getDocument(completion: { (document, err) in
        if let document = document {
            let data = document.data()!
            let start = data["start"] as? Timestamp ?? Timestamp(date: Date())
            let end = data["start"] as? Timestamp ?? Timestamp(date: Date())
            unbookListing(listing_id: listing_id, start: start.dateValue(), end: end.dateValue())
        }
    })
    //send deny message
}
