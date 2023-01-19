//
//  MessagesView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct MessagesView: View {
<<<<<<< HEAD
    @EnvironmentObject var currentUser: CurrentUser
=======
    @Binding var tabSelection: Int

>>>>>>> ef581b2e637ab5b5d0a07535a4197a0e1f773b07
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
