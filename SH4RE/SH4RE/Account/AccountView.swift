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
            Color(UIColor(.backgroundGrey)).ignoresSafeArea()
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
