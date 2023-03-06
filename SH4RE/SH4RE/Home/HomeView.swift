//
//  HomeView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @Binding var tabSelection: Int

    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            VStack {
                Text("Home View")
            }
        }
    }
}
