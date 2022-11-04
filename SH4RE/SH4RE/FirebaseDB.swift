//
//  FirebaseDB.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import Foundation
import Firebase


//Writes new document to collection assigns it a random unique ID
func documentWrite(collectionPath : String, data:Dictionary<String,Any>) -> Bool{
    var writeSucess : Bool = false
    let db = Firestore.firestore()
    db.collection(collectionPath).addDocument(data:data)
    { err in
        if let err = err {
            print("Error writing document: \(err)")
        }else{
            print("Document sucessfully written")
            writeSucess = true
        }
    }
    return writeSucess
}

//Modifies documents data, creates document if not yet created
func documentSet(collectionPath : String, documentID : String, data:Dictionary<String,Any>) -> Bool{
    var setSucess : Bool = false
    let db = Firestore.firestore()
        db.collection(collectionPath).document(documentID).setData(data)
    { err in
        if let err = err {
            print("Error setting document: \(err)")
        }else{
            print("Document sucessfully set")
            setSucess = true
            
        }
    }
    return setSucess
}

//Modifies certain fields of documents without overwrite
func documentUpdate(collectionPath : String, documentID : String, data:Dictionary<String,Any>) -> Bool{
    var updateSucess : Bool = false
    let db = Firestore.firestore()
        db.collection(collectionPath).document(documentID).updateData(data)
    { err in
        if let err = err {
            print("Error updating document: \(err)")
        }else{
            print("Document sucessfully updated")
            updateSucess = true
            
        }
    }
    return updateSucess
}

func documentDelete(collectionPath : String, documentID : String, data:Dictionary<String,Any>) -> Bool{
    var deleteSucess : Bool = false
    let db = Firestore.firestore()
        db.collection(collectionPath).document(documentID).delete
    { err in
        if let err = err {
            print("Error deleteing document: \(err)")
        }else{
            print("Document sucessfully deleted")
            deleteSucess = true
            
        }
    }
    return deleteSucess
}

func documentRead(collectionPath : String, documentID : String, completion: @escaping ((DocumentSnapshot)?)->Void){
    let db = Firestore.firestore()
    db.collection(collectionPath).document(documentID).addSnapshotListener { (docSnapshot, error) in
        if let error = error {
            print("Error reading document: \(error)")
            completion(nil)
        }else{
            print("Document sucessfully read")
            completion(docSnapshot)
        }
    }
    return
}

func collectionRead(collectionPath : String, completion: @escaping ((QuerySnapshot)?)->Void){
    let db = Firestore.firestore()
    db.collection(collectionPath).getDocuments(){ (querySnapshot, error) in
        if let error = error {
            print("Error reading collection: \(error)")
            completion(nil)
        }else{
            print("Collection sucessfully read")
            completion(querySnapshot)
        }
    }
    return
}
