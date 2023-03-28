//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct MessagesChat: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: ChatLogViewModel
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    static let emptyScrollToString = "Empty"
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
            profilePicture = vm.profilePic
        }

    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message)
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
}


