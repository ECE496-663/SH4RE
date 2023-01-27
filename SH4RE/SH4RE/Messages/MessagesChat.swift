//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI

struct MessagesChat: View {
    
    @State var chatText = ""
    @State var errorMessage = ""
    @State var chatMessages = [ChatMessage]()
    @State var count = 0
    
    static let emptyScrollToString = "Empty"
    
    
    // TODO: Bryan
    var otherUserId: String
    
    init(otherUserId: String) {
        self.otherUserId = otherUserId
        
//        fetchUser()
//
//        fetchMessages(otherUserId)
    }
    
    var body: some View {
        ZStack {
            messagesView
            VStack(spacing: 0) {
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationTitle("random@test.com")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        //                        ForEach(allChatMessages) { message in
                        //                            MessageView(message: message)
                        //                        }
                        
                        HStack{ Spacer() }
                            .id(Self.emptyScrollToString)
                    }
                    //                    .onReceive(allChatMessages.$count) { _ in
                    //                        withAnimation(.easeOut(duration: 0.5)) {
                    //                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    //                        }
                    //                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
    }
    
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            ZStack {
                Placeholder()
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                // handle send here
            } label: {
                Text("Send")
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color("PrimaryDark"))
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    func fetchMessages() {
        
//        firestoreListener?.remove()
//        chatMessages.removeAll()
//        firestoreListener = FirebaseManager.shared.firestore
//            .collection(FirebaseConstants.messages)
//            .document(getCurrentUserUid())
//            .collection(otherUserId)
//            .order(by: FirebaseConstants.timestamp)
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    self.errorMessage = "Failed to listen for messages: \(error)"
//                    print(error)
//                    return
//                }
//
//                querySnapshot?.documentChanges.forEach({ change in
//                    if change.type == .added {
//                        do {
//                            if let cm = try change.document.data(as: ChatMessage.self) {
//                                self.chatMessages.append(cm)
//                                print("Appending chatMessage in ChatLogView: \(Date())")
//                            }
//                        } catch {
//                            print("Failed to decode message: \(error)")
//                        }
//                    }
//                })
//
//                DispatchQueue.main.async {
//                    self.count += 1
//                }
//            }
    }
    
    func handleSend() {
        print(chatText)
        
//        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
//            .document(getCurrentUserUid())
//            .collection(otherUserId)
//            .document()
//
//        let msg = ChatMessage(id: nil, fromId: getCurrentUserUid(), toId: otherUserId, text: chatText, timestamp: Date())
//
//        try? document.setData(from: msg) { error in
//            if let error = error {
//                print(error)
//                self.errorMessage = "Failed to save message into Firestore: \(error)"
//                return
//            }
//
//            print("Successfully saved current user sending message")
//
//            self.chatText = ""
//            self.count += 1
//        }
//
//        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
//            .document(otherUserId)
//            .collection(getCurrentUserUid())
//            .document()
//
//        try? recipientMessageDocument.setData(from: msg) { error in
//            if let error = error {
//                print(error)
//                self.errorMessage = "Failed to save message into Firestore: \(error)"
//                return
//            }
//
//            print("Recipient saved message as well")
//        }
    }
}

struct MessageView: View {
    @ObservedObject var currentUser = CurrentUser()
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == getCurrentUserUid() {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct Placeholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .keyboardType(.numberPad)
                .foregroundColor(Color("TextGrey"))
                .font(.body)
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}



struct MessagesChat_Previews: PreviewProvider {
    
    static var previews: some View {
        MessagesChat(otherUserId: "123")
    }
}
