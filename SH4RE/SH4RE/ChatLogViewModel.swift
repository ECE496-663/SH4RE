//
//  ChatLogViewModel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let fromId = data["fromId"] as? String ?? ""
                        let toId = data["toId"] as? String ?? ""
                        let text = data["text"] as? String ?? ""
                        let date = data["timestamp"] as? Date ?? Date()
                        let isRequest = data["isRequest"] as? Bool ?? false
                        let listingTitle = data["listingTitle"] as? String ?? ""
                        let datesRequested = data["datesRequested"] as? String ?? ""
                        let listingId = data["listingId"] as? String ?? ""
                        let requestId = data["requestId"] as? String ?? ""

                        let cm = ChatMessage(id: change.document.documentID, fromId: fromId, toId: toId, text: text, timestamp: date, isRequest: isRequest, listingTitle: listingTitle, datesRequested:datesRequested, listingId: listingId, requestId:requestId)
                        //print(cm)
                        self.chatMessages.append(cm)
                    }
                })

                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()

        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date(), isRequest: false, listingTitle: "", datesRequested: "", listingId: "", requestId:"")

        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }

            self.persistRecentMessage()

            self.chatText = ""
            self.count += 1
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)

        let data = [
            FirebaseConstants.timestamp: Date(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            "name": chatUser.name,
            "isRequest": false,
            "listingTitle": "",
            "datesRequested": "",
            "listingId": "",
            "requestId": ""
            
        ] as [String : Any]

        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
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
           FirebaseConstants.fromId: toId,
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
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(uid)

        recipDoc.setData(recipientRecentMessageDictionary) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    
    @Published var count = 0
}

