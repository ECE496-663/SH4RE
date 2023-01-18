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

    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    
    @EnvironmentObject var currentUser: CurrentUser
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (currentUser.isGuest()) {
                GuestView().environmentObject(currentUser)
            }
            else {
                VStack {
                    Button(action: {
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
                            .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                            .background(.white)
                            .cornerRadius(40)
                            .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.init(UIColor(named: "PrimaryDark")!), lineWidth: 2))
                    }
                }
            }
        }
    }
}
