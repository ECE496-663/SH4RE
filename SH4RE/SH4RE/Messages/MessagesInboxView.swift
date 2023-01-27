//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesInboxView: View {
    @Binding var tabSelection: Int
    @State private var searchQuery: String = ""
    
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    @ObservedObject var currentUser = CurrentUser()
    
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (username.isEmpty) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else {
                NavigationView {
                    VStack {
                        customNavBar
                        messagesView
                    }
                    .navigationBarHidden(true)
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
                
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: screenSize.width * 0.9, height: 20)
                    .padding([.top])
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var messagesView: some View {
        // make list of users here
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        // pass in user that is is with this
                        MessagesChat(otherUserId: "123")
                    } label: {
                        HStack(spacing: 16) {
                            Image("placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                            
                            
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.body)
                                    .foregroundColor(.black)
                                Text("Message sent to user")
                                    .font(.callout)
                                    .foregroundColor(.grey)
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.callout)
                                .foregroundColor(.black)
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
}

struct MessagesInboxView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesInboxView(tabSelection: .constant(1))
    }
}
