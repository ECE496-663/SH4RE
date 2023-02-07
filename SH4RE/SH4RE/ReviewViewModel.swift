//
//  ReviewViewModel.swift
//  SH4RE
//
//  Created by Bryan Brown on 2023-01-24.
//

import Foundation
import Firebase
import SwiftUI


struct  Review: Identifiable{
    var id :String =  UUID().uuidString
    var uid : String
    var lid:String
    var rating:Int
    var description:String
}

func postReview(review : Review){
    let db = Firestore.firestore()
    let ref = db.collection("User Info").document(review.uid).collection("Reviews").document()
    let data: [String: Any] = ["lid": review.lid, "rating": review.rating, "description" : review.description]
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
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let id = document.documentID
            let lid = data["lid"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let rating : Int = data["rating"] as! Int
            let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description)
            reviews.append(review)
            
            if reviews.count == snapshot?.documents.count {
                completion(reviews)
            }
        })
    }
}

func getListingReviews(uid: String, lid:String, completion: @escaping([Review]) -> Void) {
    var reviews = [Review]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").whereField("lid", isEqualTo: lid).getDocuments() { (snapshot, error) in
        snapshot?.documents.forEach({ (document) in
            let data = document.data()
            let id = document.documentID
            let lid = data["lid"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let rating : Int = data["rating"] as! Int
            let review = Review(id:id,uid:uid, lid:lid, rating:rating, description:description)
            reviews.append(review)
            
            if reviews.count == snapshot?.documents.count {
                completion(reviews)
            }
        })
    }
}

func getUserRating(uid: String, completion: @escaping(Float) -> Void) {
    var ratings = [Float]()
    Firestore.firestore().collection("User Info").document(uid).collection("Reviews").getDocuments() { (snapshot, error) in
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

