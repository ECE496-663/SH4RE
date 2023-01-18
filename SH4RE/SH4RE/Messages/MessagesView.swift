//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
    @Binding var tabSelection: Int

    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (username.isEmpty) {
                GuestView()
            }
            else {
                VStack {
                    Text("Messages View")
                }
            }
        }
    }
}
