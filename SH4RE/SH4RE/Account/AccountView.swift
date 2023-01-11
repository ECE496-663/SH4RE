//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct AccountView: View {
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (username.isEmpty) {
                GuestView()
            }
            else {
                VStack {
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.set("", forKey: "UID")
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

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
