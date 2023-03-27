//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI

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
            
            VStack {
                HStack {
                    Text("Has this item been returned?")
                    Spacer()
                    Button(action: {
                        // TODO: bryan add mark as returned message to send leave review
                    }) {
                        Text("Confirm")
                    }
                }
                    .padding()
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
                    getUserName(uid: getCurrentUserUid(), completion: { name in
                        reviewname = name
                    })
                    
                    let review = Review(uid: getCurrentUserUid(), lid: listingId, rating: Float(reviewRating), description: review, name: reviewname)
                    postReview(review: review)
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
                listingId = vm.chatMessages[0].listingId
            }
        }
    }
}


