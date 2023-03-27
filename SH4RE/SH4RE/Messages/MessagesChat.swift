//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI
import Firebase

struct MessagesChat: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: ChatLogViewModel
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    static let emptyScrollToString = "Empty"
    @State private var showPopUp = false
    @State private var reviewRating = 0.0
    @State private var review: String = ""
    @State var listingId: String = ""
    @State var rentalNeedsReturn = "no"

    @State private var profilePicture = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var name = ""
    @State private var uid = ""
    
    var body: some View {
        ZStack {
            messagesView
            VStack(spacing: 0) {
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
            leaveReview
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }.onAppear(){
            self.hasUnreturnedRental(toId: vm.chatUser, completion: { ret in
                rentalNeedsReturn = ret
            })
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.primaryDark)
                }
                .padding(.bottom)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Image(uiImage: profilePicture)
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(height: screenSize.height * 0.03)
                    .padding(.bottom)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text(vm.chatUser?.name ?? "")
                    .padding(.bottom)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView(uid: $uid, profilePicture: $profilePicture, tabSelection: $tabSelection, currentUser: _currentUser))
                {
                    Image(systemName: "info.circle.fill")
                }
                .padding(.bottom)
            }
        }
        .onAppear() {
            name = vm.chatUser?.name ?? "error" // if reverting back to name
            uid = vm.chatUser?.uid ?? ""
        }
    }
    
    private var messagesView: some View {
        VStack {
            
            if(rentalNeedsReturn != "no" ){
                VStack {
                    HStack {
                        Text("Has this item been returned?")
                        Spacer()
                        Button(action: {
                            self.markReturned(toId: vm.chatUser, docId: rentalNeedsReturn)
                        }) {
                            Text("Confirm")
                        }
                    }
                    .padding()
                }
            }
            
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message, showPopUp: $showPopUp)
                        }
                        
                        HStack{ Spacer() }
                            .id(Self.emptyScrollToString)
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }
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
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                    .onChange(of: vm.chatText) { value in
                            if value.contains("\n") {
                                vm.chatText = value.replacingOccurrences(of: "\n", with: "")
                            }
                        }
            }
            .frame(height: 40)
            
            Button {
                if (!vm.chatText.isEmpty) {
                    vm.handleSend()
                }
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(vm.chatText.isEmpty ? Color.grey : Color.primaryDark)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var leaveReview: some View {
        PopUp(show: $showPopUp) {
            VStack {
                Text("Leave review for \(vm.chatUser?.name ?? "")!")
                    .fixedSize(horizontal: false, vertical: true)
                    .bold()
                Spacer()
                
                RatingsView(rating: $reviewRating)
                    .scaleEffect(2)
                
                Spacer()
                
                TextField("Description", text: $review,  axis: .vertical)
                    .lineLimit(5...10)
                    .textFieldStyle(textInputStyle())
                    .padding()
                
                Button(action: {
                    showPopUp.toggle()
                    
                    var reviewname: String = ""
                    guard let uid = self.vm.chatUser?.uid else{
                        return
                    }
                    
                    guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
                    
                    getUserName(uid: uid, completion: { name in
                        
                        Firestore.firestore().collection("Listings").document(listingId).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()!
                                let ownerId = data["UID"] as? String ?? ""
                                
                                var reviewToPost:Review
                                if ownerId == uid{
                                    reviewToPost = Review(uid: uid, lid: listingId, rating: Float(reviewRating), description: review, name: reviewname)
                                }else{
                                    reviewToPost = Review(uid: uid, lid: "renter", rating: Float(reviewRating), description: review, name: reviewname)
                                }
                                Firestore.firestore().collection("messages").document(fromId).collection(uid).whereField("isReviewRequest", isEqualTo: true).getDocuments() {(snapshot, err) in
                                    snapshot?.documents.forEach({ (document) in
                                        Firestore.firestore().collection("messages").document(fromId).collection(uid).document(document.documentID).delete()
                                        var idx = 0
                                        for message in vm.chatMessages{
                                            if message.isReviewRequest{
                                                vm.chatMessages.remove(at: idx)
                                                idx-=1
                                            }
                                            idx+=1
                                        }
                                    })
                                }
                                Firestore.firestore().collection("recent_messages").document(fromId).collection("messages").document(uid).updateData(["text": "Thanks for leaving a review"])
                                postReview(review: reviewToPost)
                            }
                        }
                    })
                })
                {
                    Text("Send")
                }
                .buttonStyle(primaryButtonStyle())
            
                Button(action: {
                    showPopUp.toggle()
                })
                {
                    Text("Cancel")
                }
                .buttonStyle(secondaryButtonStyle())
            }
            .padding()
            .frame(width: screenSize.width * 0.9, height: 420)
            .background(.white)
            .cornerRadius(8)
            .onAppear(){
                for message in vm.chatMessages{
                    if (message.isRequest){
                        listingId = message.listingId
                    }
                }
            }
        }
    }
    
    func hasUnreturnedRental(toId: ChatUser?,completion: @escaping (String) -> Void)
    {
        guard let toId = toId else{
            return
        }
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("Listings").whereField("UID", isEqualTo: fromId).getDocuments() {(snapshotIds, error) in
            snapshotIds?.documents.forEach({ (document) in
                let docId = document.documentID
                db.collection("Listings").document(docId).collection("Requests").whereField("UID", isEqualTo: toId.uid).getDocuments() {(snapshot, err) in
                    snapshot?.documents.forEach({ (document) in
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let status = data["status"] as? String ?? ""
                        let startDate = data["start"] as? Timestamp ?? Timestamp(date:Date(timeIntervalSince1970: 0))
                        let returned = data["returned"] as? String ?? "no"
                        if(startDate.dateValue() != Date(timeIntervalSince1970: 0) && startDate.dateValue() < Date() && returned == "no" && status == "accepted"){
                            completion(docId)
                        }
                    })
                }
            })
        }
        completion("no")
    }

    func markReturned(toId: ChatUser?, docId: String){
        guard let toId = toId else{
            return
        }
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("Listings").document(docId).collection("Requests").whereField("UID", isEqualTo: toId.uid).getDocuments() {(snapshot, err) in
            snapshot?.documents.forEach({ (document) in
                db.collection("Listings").document(docId).collection("Requests").document(document.documentID).updateData(["returned":"yes"])
            })
        }
        self.rentalNeedsReturn = "no"
        sendRentalStatusMessage(statusMessage: "", messagePreview: "Please Leave a Review", userId: fromId, renterId: toId.uid, title: "", isReviewRequest: true)
        
    }
}



