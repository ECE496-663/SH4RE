//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
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
                        let rm = RecentMessage(id: docId, text: text, name:name, fromId: fromId, toId: toId, timestamp: timestamp)
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

struct MessagesInboxView: View {
    @Binding var tabSelection: Int
    @State  var searchQuery: String = ""
    @EnvironmentObject var currentUser: CurrentUser
    @ObservedObject var vm = MainMessagesViewModel()
    @State var shouldNavigateToChatLogView = false
    var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    var body: some View {

        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else {
                NavigationView {
                    VStack {
                        customNavBar
                        messagesView
                        NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                            MessagesChat(vm: chatLogViewModel)
                        }
                    }
                }.onAppear(){
                    vm.fetchCurrentUser()
                    vm.fetchRecentMessages()
                }
            }
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Messages")
                    .font(.title2)
                    .fontWeight(.bold)
                
//                TextField("Search", text: $searchQuery)
//                    .textFieldStyle(.roundedBorder)
//                    .frame(width: screenSize.width * 0.9, height: 20)
//                    .padding([.top])
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var messagesView: some View {
        // make list of users here
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                                               
                        self.chatUser = .init(id: uid, uid: uid, name: recentMessage.name)
                       
                       self.chatLogViewModel.chatUser = self.chatUser
                       self.chatLogViewModel.fetchMessages()
                       self.shouldNavigateToChatLogView.toggle()

                       
                    } label: {
                        HStack(spacing: 16) {
                            Image("placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                            
                            
                            VStack(alignment: .leading) {
                                Text(recentMessage.name)
                                    .font(.body)
                                    .foregroundColor(.black)
                                Text(recentMessage.text)
                                    .font(.callout)
                                    .foregroundColor(.grey)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.callout)
                                .foregroundColor(.black)
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
        
    @State var chatUser: ChatUser?
    
}
