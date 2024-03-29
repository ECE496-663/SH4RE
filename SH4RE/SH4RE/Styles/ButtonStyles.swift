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
    private var isDisabled: Bool

    init(width: CGFloat = screenSize.width * 0.8, tall: Bool = false, isDisabled: Bool = false) {
        self.width = width
        self.height = tall ? 60 : 40
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .fontWeight(.semibold)
            .frame(width: width, height: height)
            .foregroundColor(.white)
            .background(Color.primaryDark)
            .cornerRadius(40)
            .opacity(isDisabled ? 0.5 : 1)
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
    private var isDisabled: Bool

    init(width: CGFloat = screenSize.width * 0.8, tall: Bool = false, isDisabled: Bool = false) {
        self.width = width
        self.height = tall ? 60 : 40
        self.isDisabled = isDisabled
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
            .opacity(isDisabled ? 0.5 : 1)
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
                Text("primaryButtonStyle DISABLED")
            })
            .buttonStyle(primaryButtonStyle(isDisabled: true))
            
            Button(action: {}, label:
            {
                Text("secondaryButtonStyle")
            })
            .buttonStyle(secondaryButtonStyle())
            
            Button(action: {}, label:
            {
                Text("secondaryButtonStyle DISABLED")
            })
            .buttonStyle(secondaryButtonStyle(isDisabled: true))
        }
    }
}
