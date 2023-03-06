//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import FirebaseAuth
import Firebase

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
                        print("here")
                        currentUser.hasLoggedIn = false
                        print("here1")
                    })
                    {
                        Text("Logout")
                    }
                    .buttonStyle(secondaryButtonStyle())
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
