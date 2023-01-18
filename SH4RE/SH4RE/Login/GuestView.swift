//
//  GuestView.swift
//  SH4RE
//
//  Created by November on 2023-01-06.
//

import SwiftUI
import FirebaseAuth

struct GuestView: View {
    @EnvironmentObject var currentUser: CurrentUser
    var body: some View {
        VStack {
            Text("You are currently logged in as a Guest, to make requests to rent items or make your own listings please login in to your account")
                .font(.system(size: 16))
                .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                .frame(maxWidth: screenSize.width * 0.8)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                currentUser.hasLoggedIn = false
            })
            {
                Text("Login to your account")
                    .fontWeight(.bold)
                    .frame(width: screenSize.width * 0.8, height: 40)
                    .foregroundColor(.white)
                    .background(Color.init(UIColor(named: "PrimaryDark")!))
                    .cornerRadius(40)
                    .padding(.bottom)
            }
        }
    }
}

struct GuestView_Previews: PreviewProvider {
    static var previews: some View {
        GuestView()
    }
}
