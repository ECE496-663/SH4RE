//
//  UnverifiedView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-04-01.
//

import SwiftUI

struct UnverifiedView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    @State var showSentPopUp: Bool = false
    
    var body: some View {
        VStack {
            Text("Your email is currently unverified.")
                .fontWeight(.bold)
                .foregroundColor(.primaryDark)
                .multilineTextAlignment(.center)
            
            Text("Please check your inbox for a verification email or press the button below to send another.")
                .font(.system(size: 16))
                .foregroundColor(.primaryDark)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                showSentPopUp.toggle()
                currentUser.sendVerificationMail()
            })
            {
                Text("Send verification email")
            }
            .buttonStyle(primaryButtonStyle())
        }
        .frame(maxWidth: screenSize.width * 0.9)
        
        sentPopUp
    }
    
    private var sentPopUp: some View {
        PopUp(show: $showSentPopUp) {
            VStack {
                Text("Email sent. Please check your inbox.")
                    .bold()
                    .padding(.bottom)
                Button(action: {
                    showSentPopUp.toggle()
                })
                {
                    Text("OK")
                }
                .buttonStyle(primaryButtonStyle())
            }
            .padding()
            .frame(width: screenSize.width * 0.9, height: 130)
            .background(.white)
            .cornerRadius(30)
        }
    }
}

struct UnverifiedView_Previews: PreviewProvider {
    static var previews: some View {
        UnverifiedView(tabSelection: .constant(1))
    }
}
