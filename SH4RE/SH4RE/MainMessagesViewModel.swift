//
//  MainMessagesViewModel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    do {
                        let data = change.document.data()
                        let text = data["text"] as? String ?? ""
                        let name = data["name"] as? String ?? ""
                        let fromId = data["fromId"] as? String ?? ""
                        let toId = data["toId"] as? String ?? ""
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let isRequest = data["isRequest"] as? Bool ?? false
                        let listingTitle = data["listingTitle"] as? String ?? ""
                        let datesRequested = data["datesRequested"] as? String ?? ""
                        let listingId = data["listingId"] as? String ?? ""
                        let requestId = data["requestId"] as? String ?? ""
                        let rm = RecentMessage(id: docId, text: text, name:name, fromId: fromId, toId: toId, timestamp: timestamp, isRequest: isRequest, listingTitle: listingTitle, datesRequested:datesRequested, listingId: listingId, requestId: requestId)
                        self.recentMessages.insert(rm, at: 0)
                    }
                })
            }
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
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
                FirebaseManager.shared.currentUser = ChatUser(uid:id, name:name)
            }
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}
