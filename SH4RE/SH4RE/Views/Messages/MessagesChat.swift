//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI

struct MessagesChat: View {
    
    @State var chatText = ""
    static let emptyScrollToString = "Empty"
    
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
}

struct MessageView: View {
    @ObservedObject var currentUser = CurrentUser()
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == currentUser.getUid() {
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
        MessagesChat()
    }
}
