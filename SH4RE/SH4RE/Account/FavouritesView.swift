//
//  FavouritesView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
        }
        .navigationTitle("Favourites")
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
