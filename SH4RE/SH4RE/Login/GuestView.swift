//
//  GuestView.swift
//  SH4RE
//
//  Created by November on 2023-01-06.
//

import SwiftUI

struct GuestView: View {
    var body: some View {
        VStack {
            Text("You are currently logged in as a Guest, to make requests to rent items or make your own listings please login in to your account")
                .font(.system(size: 16))
                .foregroundColor(customColours["primaryDark"]!)
                .frame(maxWidth: screenSize.width * 0.8)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                UserDefaults.standard.set("", forKey: "UID")
            })
            {
                Text("Login to your account")
                    .fontWeight(.bold)
                    .frame(width: screenSize.width * 0.8, height: 40)
                    .foregroundColor(.white)
                    .background(customColours["primaryDark"]!)
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
