//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
    @Binding var tabSelection: Int
    @State private var searchQuery: String = ""
    
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (username.isEmpty) {
                GuestView()
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
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image("placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .border(.black)
                        
                        
                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.body)
                            Text("Message sent to user")
                                .font(.callout)
                                .foregroundColor(Color("TextGrey"))
                        }
                        Spacer()
                        
                        Text("22d")
                            .font(.callout)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
}

struct MessagesView_Previews_helper: View {
    @State private var tabSelection = 3
    
    var body: some View {
        MessagesView(tabSelection: $tabSelection)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView_Previews_helper()
    }
}
