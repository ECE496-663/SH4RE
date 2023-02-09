//
//  ButtonStyles.swift
//  SH4RE
//
//  Created by Americo on 2023-01-23.
//

import SwiftUI

/// Styles buttons in the primarty button style when used in `.buttonStyle()`
///
/// `width` specifies width, default:`screenSize.width * 0.8`
///
/// `tall` specifies whether its  a normal or tall button. default: `false` (normal height)
struct primaryButtonStyle: ButtonStyle{
    private var width: CGFloat = screenSize.width * 0.8
    private var height: CGFloat

    init(width: CGFloat = screenSize.width * 0.8, tall: Bool = false) {
        self.width = width
        self.height = tall ? 60 : 40
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .fontWeight(.semibold)
            .frame(width: width, height: height)
            .foregroundColor(.white)
            .background(Color.primaryDark)
            .cornerRadius(40)
    }
}

/// Styles buttons in the primarty button style when used in `.buttonStyle()`
///
/// `width` specifies width, default:`screenSize.width * 0.8`
///
/// `tall` specifies whether its  a normal or tall button. default: `false` (normal height)
struct secondaryButtonStyle: ButtonStyle{
    private var width: CGFloat = screenSize.width * 0.8
    private var height: CGFloat

    init(width: CGFloat = screenSize.width * 0.8, tall: Bool = false) {
        self.width = width
        self.height = tall ? 60 : 40
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .fontWeight(.semibold)
            .frame(width: width, height: height)
            .foregroundColor(.primaryDark)
            .background(.white)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.primaryDark, lineWidth: 2)
            )
    }
}



struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: {}, label:
            {
                Text("primaryButtonStyle")
            })
            .buttonStyle(primaryButtonStyle())
            Button(action: {}, label:
            {
                Text("secondaryButtonStyle")
            })
            .buttonStyle(secondaryButtonStyle())
        }
    }
}
