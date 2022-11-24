//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            VStack {
                Text("Account View")
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
