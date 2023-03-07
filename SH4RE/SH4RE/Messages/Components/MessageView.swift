//
//  MessageView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    @State var requestStatus: Bool = false
    @State private var requestResponed = true
    
    var body: some View {
        VStack {
            if message.fromId == getCurrentUserUid() {
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        // TODO: add functionality for accepting/denying requests
                        if (message.isRequest) {
                            Text("Request sent!").italic()
                                .foregroundColor(.white)
                            HStack {
                                Text("Item: ")
                                    .foregroundColor(.white)
                                Text(message.listingTitle).bold()
                                    .foregroundColor(.white)
                            }
                            HStack {
                                Text("Dates: ")
                                    .foregroundColor(.white)
                                Text(message.datesRequested).bold()
                                    .foregroundColor(.white)
                            }
                            if(requestStatus){
                                Button(action: {
                                    cancelRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.fromId, renterId: message.toId)
                                    requestStatus = false
                                })
                                {
                                    Text("Cancel Request")
                                }
                                .buttonStyle(secondaryButtonStyle())
                            }
                        }
                        else {
                            Text(message.text.replacingOccurrences(of: "\n", with: ""))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        if (message.isRequest) {
                            Text("New Request!").italic()
                                .foregroundColor(.white)
                            HStack {
                                Text("Item: ")
                                    .foregroundColor(.white)
                                Text(message.listingTitle).bold()
                                    .foregroundColor(.white)
                            }
                            HStack {
                                Text("Dates: ")
                                    .foregroundColor(.white)
                                Text(message.datesRequested).bold()
                                    .foregroundColor(.white)
                            }
                                if(requestStatus){
                                    Button(action: {
                                        acceptRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = false
                                    })
                                    {
                                        Text("Accept Request")
                                    }
                                    .buttonStyle(primaryButtonStyle())
                                    
                                    Button(action: {
                                        denyRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = false
                                    })
                                    {
                                        Text("Deny Request")
                                    }
                                    .buttonStyle(secondaryButtonStyle())
                                    }

                            
                            
                        } else {
                            Text(message.text.replacingOccurrences(of: "\n", with: ""))
                                .foregroundColor(.black)
                        }
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
        .onAppear(){
            if (message.isRequest){
                isRequestPending(requestId: message.requestId, listingId: message.listingId, completion: {isPending in
                    requestStatus = isPending
                    print(isPending)
                    print(message.text)
                    print(message.toId)
                    print(message.fromId)
                })
            }
        }
    }
}
