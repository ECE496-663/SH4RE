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
            Color(UIColor(.primaryLight))
                .ignoresSafeArea()
            Image(uiImage: UIImage(named:"Logo")!)
                .resizable()
                .frame(maxWidth: screenSize.width * 0.75, maxHeight: screenSize.height * 0.3)
                .foregroundColor(.white)
                .position(x: screenSize.width * 0.5, y: screenSize.height * 0.4)
        }
    }
}

struct LandingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
