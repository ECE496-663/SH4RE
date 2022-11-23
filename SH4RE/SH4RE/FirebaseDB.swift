//
//  FirebaseDB.swift
//  SH4RE
//
//  Created by October on 2022-11-02.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI

//Writes new document to collection assigns it a random unique ID
func documentWrite(collectionPath : String, data:Dictionary<String,Any>) -> String{
    let db = Firestore.firestore()
    let ref = db.collection(collectionPath).document()
    let id = ref.documentID
    ref.setData(data)
    { err in
        if let err = err {
            print("Error writing document: \(err)")
        }else{
            print("Document sucessfully written")
        }
    }
    return id
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

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

public class StorageManager: ObservableObject {
    let storage = Storage.storage()
    
    func upload(image: UIImage, path: String) {
        // Create a storage reference
        let storageRef = storage.reference().child(path)
        
        // Resize the image to 200px with a custom extension
        let resizedImage = image.aspectFittedToHeight(200)
        
        // Convert the image into JPEG and compress the quality to reduce its size
        let data = resizedImage.jpegData(compressionQuality: 0.2)
        
        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Upload the image
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }
            }
        }
    }
}
