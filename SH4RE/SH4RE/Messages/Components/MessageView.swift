//
//  MessageView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == getCurrentUserUid() {
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        // TODO: add functionality for accepting/denying requests
//                        if (message.isARequest) {
//                            Text("Request sent!").italic()
//                                .foregroundColor(.white)
//                            HStack {
//                                Text("Item: ")
//                                    .foregroundColor(.white)
//                                Text("Canon 7D 2019").bold()
//                                    .foregroundColor(.white)
//                            }
//                            HStack {
//                                Text("Dates: ")
//                                    .foregroundColor(.white)
//                                Text("Jan. 10 - Jan. 11").bold()
//                                    .foregroundColor(.white)
//                            }
//
//                            Button(action: { print("cancel request")})
//                            {
//                                Text("Cancel Request")
//                            }
//                            .buttonStyle(secondaryButtonStyle())
//                        }
//                        else {
                            Text(message.text.replacingOccurrences(of: "\n", with: ""))
                                .foregroundColor(.white)
//                        }
                    }
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    VStack(alignment: .leading) {
//                        if (message.isARequest) {
//                            Text("New Request!").italic()
//                                .foregroundColor(.white)
//                            HStack {
//                                Text("Item: ")
//                                    .foregroundColor(.white)
//                                Text("Canon 7D 2019").bold()
//                                    .foregroundColor(.white)
//                            }
//                            HStack {
//                                Text("Dates: ")
//                                    .foregroundColor(.white)
//                                Text("Jan. 10 - Jan. 11").bold()
//                                    .foregroundColor(.white)
//                            }
//
//                            Button(action: { print("accept request")})
//                            {
//                                Text("Accept Request")
//                            }
//                            .buttonStyle(primaryButtonStyle())
//
//                            Button(action: { print("deny request")})
//                            {
//                                Text("Deny Request")
//                            }
//                            .buttonStyle(secondaryButtonStyle())
//                        } else {
                            Text(message.text.replacingOccurrences(of: "\n", with: ""))
                                .foregroundColor(.black)
//                        }
                    }
                    .padding()
                    .background(Color.darkGrey)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
