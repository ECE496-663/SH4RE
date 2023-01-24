//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    @Binding var tabSelection: Int

    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (username.isEmpty) {
                GuestView(tabSelection: $tabSelection)
            }
            else {
                VStack {
                    Text("Messages View")
                }
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(tabSelection: .constant(1))
    }
}
