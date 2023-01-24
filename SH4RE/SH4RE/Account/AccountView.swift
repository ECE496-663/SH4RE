//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct AccountView: View {
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    @Binding var tabSelection: Int

    var body: some View {
        ZStack {
            Color(UIColor(.backgroundGrey))
                .ignoresSafeArea()
            if (username.isEmpty) {
                GuestView(tabSelection: $tabSelection)
            }
            else {
                VStack {
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.set("", forKey: "UID")
                        tabSelection = 1
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
