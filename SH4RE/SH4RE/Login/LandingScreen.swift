//
//  LandingScreen.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct LandingScreen: View {
    var body: some View {
        ZStack {
            Color(UIColor(Color.init(UIColor(named: "PrimaryBase")!)))
                .ignoresSafeArea()
            Text("SH4RE")
                .foregroundColor(.white)
                .font(.system(size: 48, weight: .bold))
                .position(x: screenSize.width * 0.5, y: screenSize.height * 0.25)
        }
    }
}

struct LandingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreen()
    }
}
