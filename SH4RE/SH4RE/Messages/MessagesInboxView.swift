//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

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
                        if (vm.recentMessages.count == 0) {
                            Text("No recent chats")
                            Spacer()
                        }
                        else {
                            messagesView
                        }
                        NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                            MessagesChat(vm: chatLogViewModel, tabSelection: $tabSelection, currentUser: _currentUser)
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
                                Image("ProfilePhotoPlaceholder") // TODO: this will become a profile picture
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(recentMessage.name)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Text(recentMessage.text.replacingOccurrences(of: "\n", with: ""))
                                        .font(.callout)
                                        .foregroundColor(.darkGrey)
                                        .truncationMode(.tail)
                                        .frame(height: 10)
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
                    
                }
            .padding(.bottom, 50)
        }
    }
        
    @State var chatUser: ChatUser?
    
}
