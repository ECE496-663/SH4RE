//
//  UserModel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import Foundation

struct User {
    let uid, email, profileImageUrl: String
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: User?
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
//            self.errorMessage = "Could not find firebase uid"
//            return
//        }
        
        
//        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
//            if let error = error {
//                self.errorMessage = "Failed to fetch current user: \(error)"
//                print("Failed to fetch current user:", error)
//                return
//            }
//
//
//            guard let data = snapshot?.data() else {
//                self.errorMessage = "No data found"
//                return
//
//            }
//            let uid = data["uid"] as? String ?? ""
//            let email = data["email"] as? String ?? ""
//            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
//            self.chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl)
//
//
//        }
    }
    
}
