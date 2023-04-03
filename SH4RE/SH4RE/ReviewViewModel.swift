//
//  ReviewViewModel.swift
//  SH4RE
//
//  Created by Bryan Brown on 2023-01-24.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI


struct  Review: Identifiable{
    var id :String =  UUID().uuidString
    var uid : String
    var lid:String
    var rating:Float
    var description:String
    var name:String
    var reviewerId:String
    var profilePic: UIImage = UIImage(named: "ProfilePhotoPlaceholder")!
}

func postReview(review : Review){
    let db = Firestore.firestore()
    let ref = db.collection("User Info").document(review.uid).collection("Reviews").document()
    let data: [String: Any] = ["uid":review.reviewerId,"lid": review.lid, "rating": review.rating, "description" : review.description, "name":review.name]
    ref.setData(data)
    { err in
        if let err = err {
            print("Error writing document: \(err)")
        }else{
            print("Document sucessfully written")
        }
    }
}

func getUserReviews(uid: String, completion: @escaping([Review]) -> Void) {
    var reviews = [Review]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").getDocuments { (snapshot, error) in
        if let snapshot = snapshot, snapshot.isEmpty {
            completion(reviews)
            return
        }
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let id = document.documentID
            let lid = data["lid"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let reviewerId = data["uid"] as? String ?? ""
            let rating : Float = data["rating"] as! Float
            
            var profilePic = UIImage(named: "ProfilePhotoPlaceholder")!
            
            Firestore.firestore().collection("User Info").document(reviewerId).getDocument() { (document, error) in
                 guard let document = document else{
                     return
                 }
                 let data = document.data()!
                 let imagePath = data["pfp_path"] as? String ?? ""

                 if(imagePath != ""){
                     let storageRef = Storage.storage().reference(withPath: imagePath)
                     storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in

                         if let error = error {
                             //Error:
                             print (error)

                         } else {
                             guard let image = UIImage(data: data!) else{
                                 return
                             }
                             profilePic = image
                             let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description, name: name, reviewerId: reviewerId, profilePic: profilePic)
                             reviews.append(review)
                             
                             if reviews.count == snapshot?.documents.count {
                                 completion(reviews)
                             }

                         }
                     }
                 }else{
                     let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description, name: name, reviewerId: reviewerId)
                     reviews.append(review)
                     
                     if reviews.count == snapshot?.documents.count {
                         completion(reviews)
                     }
                 }
             }
        })
    }
}

func getListingReviews(uid: String, lid: String, completion: @escaping([Review]) -> Void) {
    var reviews = [Review]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").whereField("lid", isEqualTo: lid).getDocuments() { (snapshot, error) in
        if let snapshot = snapshot, snapshot.isEmpty {
            completion(reviews)
            return
        }
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let id = document.documentID
            let lid = data["lid"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let reviewerId = data["uid"] as? String ?? ""
            let rating : Float = data["rating"] as! Float
            var profilePic = UIImage(named: "ProfilePhotoPlaceholder")!
            Firestore.firestore().collection("User Info").document(reviewerId).getDocument() { (document, error) in
                 guard let document = document else{
                     return
                 }
                 let data = document.data()!
                 let imagePath = data["pfp_path"] as? String ?? ""

                 if(imagePath != ""){
                     let storageRef = Storage.storage().reference(withPath: imagePath)
                     storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in

                         if let error = error {
                             //Error:
                             print (error)

                         } else {
                             guard let image = UIImage(data: data!) else{
                                 return
                             }
                             profilePic = image
                             let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description, name: name, reviewerId: reviewerId, profilePic: profilePic)
                             reviews.append(review)
                             
                             if reviews.count == snapshot?.documents.count {
                                 completion(reviews)
                             }

                         }
                     }
                 }else{
                     let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description, name: name, reviewerId: reviewerId)
                     reviews.append(review)
                     
                     if reviews.count == snapshot?.documents.count {
                         completion(reviews)
                     }
                 }
             }
            
        })
    }
}

func getUserRating(uid: String, completion: @escaping(Float) -> Void) {
    var ratings = [Float]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").getDocuments() { (snapshot, error) in
        if let snapshot = snapshot, snapshot.isEmpty {
            completion(0)
            return
        }
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let rating : Float = data["rating"] as! Float
            ratings.append(rating)
            if ratings.count == snapshot?.documents.count {
                completion(ratings.reduce(0, +)/Float(ratings.count))
            }
        })
    }
}

func getListingRating(uid: String, lid:String, completion: @escaping(Float) -> Void) {
    var ratings = [Float]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").whereField("lid", isEqualTo: lid).getDocuments() { (snapshot, error) in
        if let snapshot = snapshot, snapshot.isEmpty {
            completion(0)
            return
        }
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let rating : Float = data["rating"] as! Float
            ratings.append(rating)
            if ratings.count == snapshot?.documents.count {
                completion(Float(ratings.reduce(0, +)/Float(ratings.count)))
            }
        })
    }
}
