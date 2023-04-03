import Foundation
import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseStorage


//Functions used to extract data about users
struct User : Identifiable{
    var id :String = ""
    var name:String = ""
    var email:String = ""
    var pfpPath:String = ""
}


func getCurrentUserUid() -> String {
    let curUser = Auth.auth().currentUser

    if (curUser != nil) {
        return curUser!.uid
    }
    
    return ""
}

func getCurrentUser(completion: @escaping(User) -> Void){
    let curUser = Auth.auth().currentUser!
    let docRef = Firestore.firestore().collection("User Info").document(curUser.uid)
    docRef.getDocument{ (document, error) in
        guard error == nil else{
            print("Error reading document:", error ?? "")
            return
        }
        if let document = document, document.exists {
            let data = document.data()!
            let id = document.documentID
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let pfpPath = data["pfp_path"] as? String ?? ""
            completion(User(id:id,name:name,email:email,pfpPath:pfpPath))
        }
    }
}

func getUser(uid: String, completion: @escaping(User) -> Void){
    let docRef = Firestore.firestore().collection("User Info").document(uid)
    docRef.getDocument{ (document, error) in
        guard error == nil else{
            print("Error reading document:", error ?? "")
            return
        }
        if let document = document, document.exists {
            let data = document.data()!
            let id = document.documentID
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let pfpPath = data["pfp_path"] as? String ?? ""
            completion(User(id:id,name:name,email:email,pfpPath:pfpPath))
        }
    }
}

func fetchAllUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        Firestore.firestore().collection("User Info").getDocuments { (snapshot, error) in
            snapshot?.documents.forEach({ (document) in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let user = User(id:id,name:name,email:email)
                users.append(user)
                
                if users.count == snapshot?.documents.count {
                    completion(users)
                }
            })
        }
    }

func getUserName(uid:String, completion: @escaping(String) -> Void){
    let docRef = Firestore.firestore().collection("User Info").document(uid)
    docRef.getDocument{ (document, error) in
        guard error == nil else{
            print("Error reading document:", error ?? "")
            return
        }
        if let document = document, document.exists {
            let data = document.data()!
            let name = data["name"] as? String ?? ""
            completion(name)
        }
    }
}

func getProfilePic(uid:String, completion: @escaping(UIImage)->Void){
    Firestore.firestore().collection("User Info").document(uid).getDocument() { (document, error) in
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
                    
                    completion(image)
                    
                }
            }
        }else{
            completion(UIImage(named: "ProfilePhotoPlaceholder")!)
        }
    }
}
