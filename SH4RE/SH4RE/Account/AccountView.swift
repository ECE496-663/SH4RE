//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else {
                VStack {
                    Button(action: {
                        tabSelection = 1
                        do {
                            try Auth.auth().signOut()
                        }
                        catch {
                            print(error)
                        }
                        currentUser.hasLoggedIn = false
                    })
                    {
                        Text("Logout")
                            .fontWeight(.semibold)
                            .frame(width: screenSize.width * 0.8, height: 40)
                            .foregroundColor(.primaryDark)
                            .background(.white)
                            .cornerRadius(40)
                            .overlay(RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.primaryDark, lineWidth: 2))
                    }
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(tabSelection: .constant(1))
    }
}
