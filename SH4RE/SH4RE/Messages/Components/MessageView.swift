//
//  MessageView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    @State var requestStatus: Int = 0
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
                                if(requestStatus == 0){
                                    Button(action: {
                                        cancelRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.fromId, renterId: message.toId)
                                        requestStatus = 3
                                    })
                                    {
                                        Text("Cancel Request")
                                    }
                                    .buttonStyle(secondaryButtonStyle())
                                }
                                else if(requestStatus == 1){
                                    Text("Accepted").foregroundColor(.white)
                                }else if(requestStatus == 2){
                                    Text("Declined").foregroundColor(.white)
                                }else if(requestStatus == 3){
                                    Text("Cancelled").foregroundColor(.white)
                                }
                            }
//                            else if (message.leaveReview) { // TODO: bryan add this
//                                Button(action: {
//                                    showPopUp.toggle()
//                                })
//                                {
//                                    Text("Leave Review")
//                                }
//                                .buttonStyle(disabledButtonStyle(width: screenSize.width * 0.5))
//                                .disabled(hasAlreadyLeftReview) // TODO: bryan add this
//                            }
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
                                if (requestStatus == 0){
                                    Button(action: {
                                        acceptRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = 1
                                    })
                                    {
                                        Text("Accept Request")
                                    }
                                    .buttonStyle(primaryButtonStyle())
                                    
                                    Button(action: {
                                        denyRentalRequest(listing_id: message.listingId, rental_request_id: message.requestId, userId: message.toId, renterId: message.fromId)
                                        requestStatus = 2
                                    })
                                    {
                                        Text("Deny Request")
                                    }
                                    .buttonStyle(secondaryButtonStyle())
                                }else if(requestStatus == 1){
                                    Text("Accepted").foregroundColor(.white)
                                }else if(requestStatus == 2){
                                    Text("Declined").foregroundColor(.white)
                                }else if(requestStatus == 2){
                                    Text("Cancelled").foregroundColor(.white)
                                }
                                
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
