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
        NavigationView {
            ZStack {
                Color("BackgroundGrey").ignoresSafeArea()
                VStack {
                    Text("Search View")
                    NavigationLink(destination: ViewListingView()) {
                        Text("See Listing")
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
