//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            VStack {
                Text("Search View")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
