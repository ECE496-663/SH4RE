//
//  TextFieldStyles.swift
//  SH4RE
//
//  Created by Americo on 2023-01-24.
//

import SwiftUI

struct textInputStyle: TextFieldStyle{

    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
            .textFieldStyle(PlainTextFieldStyle())
            // Text alignment.
            .multilineTextAlignment(.leading)
            // Cursor color.
            .accentColor(.primaryDark)
            // Text color.
            .foregroundColor(.black)
            // TextField spacing.
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            // TextField border
            .background(border)
            .background(.white)
            .cornerRadius(8)
        
    }
    var border: some View {
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(
            .gray,
          lineWidth: 1
        )
    }
}


struct TextFieldStyles_PreviewsHelper: View {
    @State var username: String = ""
    var body: some View {
        TextField("Your email", text: $username)
            .frame(width: screenSize.width * 0.8)
            .textFieldStyle(textInputStyle())
    }
}

struct TextFieldStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldStyles_PreviewsHelper()
    }
}