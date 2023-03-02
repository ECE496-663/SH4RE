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
                let uid = data["UID"] as? String ?? ""
                let title = data["Title"] as? String ?? ""
                let description = data["Description"] as? String ?? ""
                let imagepath = data["image_path"] as? [String] ?? []
                let price = data["Price"] as? String ?? ""
                let timestampAvailability = data["Availability"] as? [Timestamp] ?? []
                var availability = [(Date,Date)]()
                if(timestampAvailability.count > 1){
                    for i in Swift.stride(from: 0, to: timestampAvailability.count, by:2) {
                        let start = timestampAvailability[i].dateValue()
                        let end = timestampAvailability[i+1].dateValue()
                        let booked = (start, end)
                        availability.append(booked)
                    }
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
     print(start)
     print(end)
     db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayUnion([Timestamp(date: start), Timestamp(date: end)])])
     
 }

 func unbookListing(listing_id : String, start: Date, end: Date){
     let db = Firestore.firestore()
     db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayRemove([Timestamp(date: start), Timestamp(date: end)])
     ])
 }

 func sendBookingRequest(uid: String, listing_id : String, start: Date, end: Date){
     let collectionRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests")

     collectionRef.whereField("UID", isEqualTo: uid).whereField("start", isEqualTo: Timestamp(date: start)).getDocuments() { (querySnapshot, err) in
         if let err = err {
             print("Error getting documents: \(err)")
         } else {
             if (querySnapshot!.isEmpty){

                 let startTime = Timestamp(date:start)
                 let endTime = Timestamp(date:end)
                 let requestDoc = collectionRef.document()
                 requestDoc.setData(["UID":uid, "start" : startTime, "end":endTime, "status" : "pending" ])
                 bookListing(listing_id: listing_id, start: start, end: end)
                 
                 let listingDocRef = Firestore.firestore().collection("Listings").document(listing_id)
                 
                 listingDocRef.getDocument() { (document, err) in
                     if let document = document, document.exists {
                         let data = document.data()!
                         let renterId = data["UID"] as? String ?? ""
                         let title = data["Title"] as? String ?? ""
                         let dateFormatter = DateFormatter()
                         dateFormatter.dateStyle = .short
                         
                         let msg = ChatMessage(id: nil, fromId: uid, toId: renterId, text: "Rental Request", timestamp: Date(), isRequest: true, listingTitle: title, datesRequested: dateFormatter.string(from: start) + " - " + dateFormatter.string(from: end), listingId: listing_id, requestId: requestDoc.documentID)
                         
                         let msgDocument = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                             .document(uid)
                             .collection(renterId)
                             .document()
                         
                         try? msgDocument.setData(from: msg) { error in
                             if let error = error {
                                 print(error)
                                 return
                             }
                         }
                         
                         let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
                             .document(renterId)
                             .collection(uid)
                             .document()

                         try? recipientMessageDocument.setData(from: msg) { error in
                             if let error = error {
                                 print(error)
                                 return
                             }
                         }
                         
                         let userDocRef = Firestore.firestore().collection("User Info").document(renterId)
                         
                         userDocRef.getDocument() { (document, err) in
                             if let document = document, document.exists {
                                 let data = document.data()!
                                 let renterName = data["name"] as? String ?? ""
                                 let recentMsgDoc = FirebaseManager.shared.firestore
                                     .collection(FirebaseConstants.recentMessages)
                                     .document(uid)
                                     .collection(FirebaseConstants.messages)
                                     .document(renterId)
                                 
                                 let docData = [
                                    FirebaseConstants.timestamp: Date(),
                                    FirebaseConstants.text: "Rental Request",
                                    FirebaseConstants.fromId: uid,
                                    FirebaseConstants.toId: renterId,
                                    "name": renterName,
                                    "isRequest": false,
                                    "listingTitle": "",
                                    "datesRequested": "",
                                    "listingId": "",
                                    "requestId": ""
                                    
                                 ] as [String : Any]
                                 
                                 recentMsgDoc.setData(docData) { error in
                                     if let error = error {
                                         print("Failed to save recent message: \(error)")
                                         return
                                     }
                                 }
                                 guard let currentUser = FirebaseManager.shared.currentUser else {
                                     return
                                 }
                                 let recipientRecentMessageDictionary = [
                                    FirebaseConstants.timestamp: Date(),
                                    FirebaseConstants.text: "Rental Request",
                                    FirebaseConstants.fromId: renterId,
                                    FirebaseConstants.toId: uid,
                                    "name": currentUser.name,
                                    "isRequest": false,
                                    "listingTitle": "",
                                    "datesRequested": "",
                                    "listingId": "",
                                    "requestId": ""
                                    
                                 ] as [String : Any]
                                 
                                 let recipDoc = FirebaseManager.shared.firestore
                                     .collection(FirebaseConstants.recentMessages)
                                     .document(renterId)
                                     .collection(FirebaseConstants.messages)
                                     .document(uid)
                                 
                                 recipDoc.setData(recipientRecentMessageDictionary) { error in
                                     if let error = error {
                                         print("Failed to save recent message: \(error)")
                                         return
                                     }
                                 }
                             }
                         }
                         
                         
                     } else {
                         print("Document does not exist")
                     }
                     
                 }
                 
                 
                 
                 
             }else{
                 //Add something to return to front end
                 //probably 0 is success and else a failure code
                 print("booking request already made")
             }
         }
     }
 }

 func acceptRentalRequest(listing_id: String, rental_request_id : String){
     print(listing_id)
     print(rental_request_id)
     let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)
     docRef.updateData(["status": "accepted"])
     //TODO send accept message
 }

 func denyRentalRequest(listing_id: String, rental_request_id : String){
     let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)

     docRef.updateData(["status": "denied"])

     docRef.getDocument(completion: { (document, err) in
         if let document = document {
             let data = document.data()!
             let start = data["start"] as? Timestamp ?? Timestamp(date: Date())
             let end = data["end"] as? Timestamp ?? Timestamp(date: Date())
             unbookListing(listing_id: listing_id, start: start.dateValue(), end: end.dateValue())
         }
     })
     //TODO send deny message
 }

func cancelRentalRequest(listing_id: String, rental_request_id : String){
    let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)

    docRef.updateData(["status": "canceled"])

    docRef.getDocument(completion: { (document, err) in
        if let document = document {
            let data = document.data()!
            let start = data["start"] as? Timestamp ?? Timestamp(date: Date())
            let end = data["end"] as? Timestamp ?? Timestamp(date: Date())
            unbookListing(listing_id: listing_id, start: start.dateValue(), end: end.dateValue())
        }
    })
    //TODO send cancelled message
    //remove option for renter to accept/deny
}
