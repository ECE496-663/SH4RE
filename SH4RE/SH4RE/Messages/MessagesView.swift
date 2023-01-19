//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var currentUser: CurrentUser
    @Binding var tabSelection: Int

    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (currentUser.isGuest()) {
                GuestView().environmentObject(currentUser)
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
