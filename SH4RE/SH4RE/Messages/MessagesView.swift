//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
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
