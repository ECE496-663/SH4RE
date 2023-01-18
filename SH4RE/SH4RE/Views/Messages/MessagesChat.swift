//
//  MessagesChat.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-17.
//

import SwiftUI

struct MessagesChat: View {
//    let chatUser: User?
    
    @State var chatText = ""
    
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
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("beep beep")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("PrimaryDark"))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack{ Spacer() }
                .frame(height: 50)
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        
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

private struct Placeholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .foregroundColor(Color("TextGrey"))
                .font(.body)
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
                     
                     

struct MessagesChat_Previews: PreviewProvider {
    
//    var chatUser = User(uid: "123", email: "test@test.com", profileImageUrl: "")
    
    static var previews: some View {
        MessagesChat()
    }
}
