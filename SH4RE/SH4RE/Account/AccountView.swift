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
    @ObservedObject var favouritesModel: FavouritesModel
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
                        //Remove some user specific info
                        UserDefaults.standard.setValue([""], forKey: "RecentSearchQueries")
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
        AccountView(tabSelection: .constant(1), favouritesModel: FavouritesModel())
            .environmentObject(CurrentUser())
    }
}
