//
//  MessageView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

enum RequestStatus: Int {
    case requested = 0
    case accepted = 1
    case declined = 2
    case cancelled = 3
}

struct MessageView: View {
    let message: ChatMessage
    @State var requestStatus: Int = -1
    
    @State private var requestResponed = false
    @Binding var showPopUp: Bool;
    
    var body: some View {
            VStack {
                if message.fromId == getCurrentUserUid() {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
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
                                if(requestStatus == RequestStatus.requested.rawValue){
                                    Button(action: {
                                        cancelRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.fromId, renterId: message.toId)
                                        requestStatus = RequestStatus.cancelled.rawValue
                                    })
                                    {
                                        Text("Cancel Request")
                                    }
                                    .buttonStyle(secondaryButtonStyle())
                                }
                                else if(requestStatus == RequestStatus.accepted.rawValue){
                                    Text("Accepted").foregroundColor(.white)
                                }else if(requestStatus == RequestStatus.declined.rawValue){
                                    Text("Declined").foregroundColor(.white)
                                }else if(requestStatus == RequestStatus.cancelled.rawValue){
                                    Text("Cancelled").foregroundColor(.white)
                                }
                            }
                            else if (message.isReviewRequest) {
                                Button(action: {
                                    showPopUp.toggle()
                                })
                                {
                                    Text("Leave Review")
                                }
                                .buttonStyle(secondaryButtonStyle(width: screenSize.width * 0.5))
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
                                if (requestStatus == RequestStatus.requested.rawValue){
                                    Button(action: {
                                        acceptRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = RequestStatus.accepted.rawValue
                                    })
                                    {
                                        Text("Accept Request")
                                    }
                                    .buttonStyle(primaryButtonStyle())
                                    
                                    Button(action: {
                                        denyRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = RequestStatus.declined.rawValue
                                    })
                                    {
                                        Text("Deny Request")
                                    }
                                    .buttonStyle(secondaryButtonStyle())
                                
                                }else if(requestStatus == RequestStatus.accepted.rawValue){
                                    Text("Accepted").foregroundColor(.white)
                                }else if(requestStatus == RequestStatus.declined.rawValue){
                                    Text("Declined").foregroundColor(.white)
                                }else if(requestStatus == RequestStatus.cancelled.rawValue){
                                    Text("Cancelled").foregroundColor(.white)
                                }
                                
                            }
                            else if (message.isReviewRequest) {
                                Button(action: {
                                    showPopUp.toggle()
                                })
                                {
                                    Text("Leave Review")
                                }
                                .buttonStyle(secondaryButtonStyle(width: screenSize.width * 0.5))
                            }
                            else {
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
                    getStatus(requestId: message.requestId, listingId: message.listingId, completion: {status in
                        requestStatus = status
                    })
                }
            }
    }
}
