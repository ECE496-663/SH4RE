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
    var uid : String = ""
    var title:String = ""
    var description:String = ""
    var imagepath = [String]()
    var price:String = ""
    var imageDict = UIImage()
    var availability = [Date]()
    var category = ""
    var address:Dictionary<String,Any> = [String:Any]()
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
                let timeAvailability = data["Availability"] as? [Timestamp] ?? []
                let address = data["Address"] as? Dictionary<String,Any> ?? ["latitude": -1, "longitude": -1]
                var availability:[Date] = []
                let category = data["Category"] as? String ?? ""
                for timestamp in timeAvailability{
                    availability.append(timestamp.dateValue())
                }
                return Listing(id:id,uid:uid, title:title, description:description, imagepath:imagepath, price:price, availability: availability, category: category, address: address)
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

func fetchUsersListings(uid:String, completion: @escaping ([Listing]) -> Void){
    let db = Firestore.firestore()
    var listings = [Listing]()
    db.collection("Listings").whereField("UID", isEqualTo: uid).getDocuments() {(snapshot, error) in
        
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            //Assign listing properties here
            let id = document.documentID
            let uid = data["UID"] as? String ?? ""
            let title = data["Title"] as? String ?? ""
            let description = data["Description"] as? String ?? ""
            let imagepath = data["image_path"] as? [String] ?? []
            let price = data["Price"] as? String ?? ""
            let timeAvailability = data["Availability"] as? [Timestamp] ?? []
            let address = data["Address"] as? Dictionary<String,Any> ?? ["latitude": -1, "longitude": -1]
            var availability:[Date] = []
            let category = data["Category"] as? String ?? ""
            for timestamp in timeAvailability{
                availability.append(timestamp.dateValue())
            }
            let listing = Listing(id:id,uid:uid, title:title, description:description, imagepath:imagepath, price:price, availability: availability, category: category, address: address)
            listings.append(listing)
            if listings.count == snapshot?.documents.count {
                completion(listings)
            }
        })
    }
    completion(listings)
}

func fetchSingleListing(lid:String, completion: @escaping (Listing) -> Void){
    let db = Firestore.firestore()
    let docRef = db.collection("Listings").document(lid)
    var listing = Listing()

    docRef.getDocument { (document, error) in
        let data = document!.data()
        //Assign listing properties here
        let id = lid
        let uid = data!["UID"] as? String ?? ""
        let title = data!["Title"] as? String ?? ""
        let description = data!["Description"] as? String ?? ""
        let imagepath = data!["image_path"] as? [String] ?? []
        let price = data!["Price"] as? String ?? ""
        let timeAvailability = data!["Availability"] as? [Timestamp] ?? []
        var availability:[Date] = []
        let address = data!["Address"] as? Dictionary<String,Any> ?? ["latitude": -1, "longitude": -1]
        let category = data!["Category"] as? String ?? ""
        for timestamp in timeAvailability{
            availability.append(timestamp.dateValue())
        }
        listing = Listing(id:id,uid:uid, title:title, description:description, imagepath:imagepath, price:price, availability: availability, category: category, address: address)
        completion(listing)
    }
}

func deleteListing(lid:String){
    let db = Firestore.firestore()
    db.collection("Listings").document(lid).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
        }
    }
}

func bookListing(listing_id : String, start: Date, end: Date? = nil){
    let db = Firestore.firestore()
    var bookedDates:[Date] = []
    if(end != nil){
        var date = start
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        while date <= end! {
            fmt.string(from: date)
            bookedDates.append(date)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
    }else{
        bookedDates.append(start)
    }
    
    db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayUnion(bookedDates)])
     
 }

 func unbookListing(listing_id : String, start: Date, end: Date? = nil){
     let db = Firestore.firestore()
     var bookedDates: [Date] = []
     if(end != nil){
         var date = start
         let fmt = DateFormatter()
         fmt.dateFormat = "dd/MM/yyyy"
         while date <= end! {
             fmt.string(from: date)
             bookedDates.append(date)
             date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
         }
     }else{
         bookedDates.append(start)
     }
     db.collection("Listings").document(listing_id).updateData([
        "Availability": FieldValue.arrayRemove(bookedDates)
     ])
 }

func sendBookingRequest(uid: String, listing_id : String, title:String, start: Date, end: Date? = nil){
     let collectionRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests")
     collectionRef.whereField("UID", isEqualTo: uid).whereField("start", isEqualTo: Timestamp(date: start)).getDocuments() { (querySnapshot, err) in
         if let err = err {
             print("Error getting documents: \(err)")
         } else {
              let startTime = Timestamp(date:start)
              let endTime = end != nil ? Timestamp(date:end!): nil
              let requestDoc = collectionRef.document()
              if(end != nil){
                 requestDoc.setData(["UID":uid, "start" : startTime, "end":endTime, "status" : "pending", "title": title ])
              }else{
                  requestDoc.setData(["UID":uid, "start" : startTime, "end":"nil", "status" : "pending", "title": title ])
              }
              bookListing(listing_id: listing_id, start: start, end: end)

              let listingDocRef = Firestore.firestore().collection("Listings").document(listing_id)
                 
                 listingDocRef.getDocument() { (document, err) in
                     if let document = document, document.exists {
                         let data = document.data()!
                         let renterId = data["UID"] as? String ?? ""
                         
                         if renterId != uid{
                             let title = data["Title"] as? String ?? ""
                             let dateFormatter = DateFormatter()
                             dateFormatter.dateStyle = .short
                             
                             var dateString: String
                             if(end != nil){
                                 dateString = dateFormatter.string(from: start) + " - " + dateFormatter.string(from: end!)
                             }else{
                                 dateString = dateFormatter.string(from: start)
                             }
                             
                             let msg = ["fromId": uid, "toId": renterId, "text": "Rental Request", "timestamp": Date(), "isRequest": true, "listingTitle": title, "datesRequested": dateString, "listingId": listing_id, "requestId": requestDoc.documentID]
                             
                             FirebaseManager.shared.firestore.collection(FirebaseConstants.messages).document(uid).collection(renterId).addDocument(data: msg)
                             
                             let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
                                 .document(renterId)
                                 .collection(uid)
                                 .addDocument(data: msg)
                             
                             let renterName = title
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
                             
                         }else{
                             //TODO probably just don't show user there listing in search
                             print("Can't send rental request for your own booking")
                         }
                     }else{
                         print("Document does not exist")
                     }
                 }
            }
         }
     
 }

func acceptRentalRequest(listing_id: String, rental_request_id : String, userId: String, renterId: String){
     let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)
     docRef.updateData(["status": "accepted"])
     
    docRef.getDocument() { (document, err) in
        if let document = document, document.exists {
            let data = document.data()!
            let title = data["title"] as? String ?? ""
            sendRentalStatusMessage(statusMessage: "This request has been accepted",messagePreview: "Request Accepted", userId: userId, renterId: renterId, title: title)
        }
    }
     
 }

func denyRentalRequest(listing_id: String, rental_request_id : String, userId: String, renterId: String){
     let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)

     docRef.updateData(["status": "declined"])

     docRef.getDocument(completion: { (document, err) in
         if let document = document {
             let data = document.data()!
             let start = data["start"] as? Timestamp ?? Timestamp(date: Date())
             let end = data["end"] as? Timestamp ?? nil
             let title = data["title"] as? String ?? ""
             if(end != nil) {
                 unbookListing(listing_id: listing_id, start: start.dateValue(), end: end!.dateValue())
             }else{
                 unbookListing(listing_id: listing_id, start: start.dateValue())
             }
             sendRentalStatusMessage(statusMessage: "This request has been declined",messagePreview: "Request Declined", userId: userId, renterId: renterId, title: title)
         }
     })

 }

func cancelRentalRequest(listing_id: String, rental_request_id : String, userId: String, renterId: String){
    let docRef = Firestore.firestore().collection("Listings").document(listing_id).collection("Requests").document(rental_request_id)

    docRef.getDocument(completion: { (document, err) in
        if let document = document {
            let data = document.data()!
            let start = data["start"] as? Timestamp ?? Timestamp(date: Date())
            let end = data["end"] as? Timestamp ?? nil
            let title = data["title"] as? String ?? ""
            if(end != nil) {
                unbookListing(listing_id: listing_id, start: start.dateValue(), end: end!.dateValue())
            }else{
                unbookListing(listing_id: listing_id, start: start.dateValue())
            }
            sendRentalStatusMessage(statusMessage: "This request has been cancelled",messagePreview: "Request Cancelled", userId: userId, renterId: renterId, title: title)
            docRef.delete()
        }
    })
}

func sendRentalStatusMessage(statusMessage: String, messagePreview: String, userId:String, renterId:String, title: String){
    let msg = ChatMessage(id: nil, fromId: userId, toId: renterId, text: statusMessage, timestamp: Date(), isRequest: false, listingTitle: "", datesRequested: "", listingId: "", requestId: "")
     
    let msgDocument = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
         .document(renterId)
         .collection(userId)
         .document()
    
     try? msgDocument.setData(from: msg) { error in
         if let error = error {
             print(error)
             return
         }
     }
    
     let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
         .document(userId)
         .collection(renterId)
         .document()

     try? recipientMessageDocument.setData(from: msg) { error in
         if let error = error {
             print(error)
             return
         }
     }
    
     let userDocRef = Firestore.firestore().collection("User Info").document(renterId)
    
    
     let recentMsgDoc = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(userId)
                .collection(FirebaseConstants.messages)
                .document(renterId)
            
     userDocRef.getDocument(completion: { (document, err) in
        if let document = document {
            let data = document.data()
            let name = document["name"] as? String ?? ""
            
            let docData = [
                FirebaseConstants.timestamp: Date(),
                FirebaseConstants.text: messagePreview,
                FirebaseConstants.fromId: userId,
                FirebaseConstants.toId: renterId,
                "name": name,
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
            
            let recipientRecentMessageDictionary = [
                FirebaseConstants.timestamp: Date(),
                FirebaseConstants.text: "Rental Request Accepted",
                FirebaseConstants.fromId: renterId,
                FirebaseConstants.toId: userId,
                "name": title,
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
                .document(userId)
            
            recipDoc.setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recent message: \(error)")
                    return
                }
            }
        }
    })
        
    
}

//returns status code 0:pending, 1:accepted, 2:declined, 3:cancelled, 4:error
func getStatus(requestId: String, listingId: String, completion: @escaping(Int)->()){
    let docRef = Firestore.firestore().collection("Listings").document(listingId).collection("Requests").document(requestId)
    docRef.getDocument(completion: { (document, err) in
        if let document = document {
            if let data = document.data() {
                let status = data["status"] as? String ?? "pending"
                if(status == "pending"){
                    completion(0)
                }else if(status == "accepted"){
                    completion(1)
                }else if(status == "declined"){
                    completion(2)
                }else{
                    completion(3)
                }
            }else{
                completion(4)
            }
        }
    })
}
