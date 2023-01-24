
import Foundation
import Firebase
import SwiftUI
import FirebaseAuth

struct User : Identifiable{
    var id :String
    var name:String
    var email:String
}

func getCurrentUserUid() -> String{
    let curUser = Auth.auth().currentUser!
    return curUser.uid
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
            completion(User(id:id,name:name,email:email))
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
