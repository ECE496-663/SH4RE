//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct MessagesInboxView: View {
    @Binding var tabSelection: Int
    @State  var searchQuery: String = ""
    @EnvironmentObject var currentUser: CurrentUser
    @ObservedObject var vm = MainMessagesViewModel()
    @ObservedObject var favouritesModel: FavouritesModel
    @State var profilePicDict : [String:UIImage] = [:]
    
    var body: some View {

        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else if (!currentUser.isEmailVerified()) {
                UnverifiedView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else {
                NavigationStack {
                    VStack {
                        customNavBar
                        if (vm.recentMessages.count == 0) {
                            Text("No recent chats")
                            Spacer()
                        }
                        else {
                            messagesView
                        }
                    }
                }
                .onAppear(){
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
    
    private func getCLVM(recentMessage: RecentMessage) -> ChatLogViewModel {
        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
        let CLVM = ChatLogViewModel(chatUser: ChatUser(id: uid, uid: uid, name: recentMessage.name))
        CLVM.profilePic = profilePicDict[recentMessage.toId] ?? UIImage(named: "ProfilePhotoPlaceholder")!
        return CLVM
    }
    
    private var messagesView: some View {
        
        ScrollView (showsIndicators: false) {
                ForEach(vm.recentMessages) { recentMessage in
                    
                    VStack {
                        NavigationLink(destination:{
                            MessagesChat(vm: getCLVM(recentMessage: recentMessage), favouritesModel: favouritesModel, tabSelection: $tabSelection, currentUser: _currentUser)
                            
                        }, label: {
                            HStack(spacing: 16) {
                                Image(uiImage: profilePicDict[recentMessage.toId] ?? UIImage(named: "ProfilePhotoPlaceholder")!)
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
                        })
                        Divider()
                            .padding(.vertical, 8)
                    }.padding(.horizontal)
                    
                }
            .padding(.bottom, 50)
        }.onAppear(){
            for recentMessage in self.vm.recentMessages{
                Firestore.firestore().collection("User Info").document(recentMessage.toId).getDocument() { (document, error) in
                    guard let document = document else{
                        return
                    }
                    let data = document.data()!
                    let imagePath = data["pfp_path"] as? String ?? ""
                    
                    if(imagePath != ""){
                        let storageRef = Storage.storage().reference(withPath: imagePath)
                        storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                            
                            if let error = error {
                                //Error:
                                print (error)
                                
                            } else {
                                guard let image = UIImage(data: data!) else{
                                    return
                                }
                                
                                self.profilePicDict[recentMessage.toId] = image
                                
                            }
                        }
                    }else{
                        self.profilePicDict[recentMessage.toId] = UIImage(named: "ProfilePhotoPlaceholder")!
                    }
                    
                }
            }
        }
        .refreshable {
            vm.fetchRecentMessages()
        }
    }
        
    @State var chatUser: ChatUser?
    
}


