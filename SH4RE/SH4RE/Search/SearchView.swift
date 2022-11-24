//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct SearchView: View {
    let screenSize: CGRect = UIScreen.main.bounds

    
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            NavigationView {
                VStack {
                    NavigationLink(destination: ViewListingView()) {
                        Text("View Listing")
                    }
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
