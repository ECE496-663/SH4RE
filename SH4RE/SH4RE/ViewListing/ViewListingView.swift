//
//  ViewListingView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct ViewListingView: View {
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            VStack {
                Text("View Listing View")
            }
        }
    }
}

struct ViewListingView_Previews: PreviewProvider {
    static var previews: some View {
        ViewListingView()
    }
}
