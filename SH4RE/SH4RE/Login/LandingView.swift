//
//  LandingScreen.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        ZStack {
            Color(UIColor(.primaryBase))
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
        LandingView()
    }
}
