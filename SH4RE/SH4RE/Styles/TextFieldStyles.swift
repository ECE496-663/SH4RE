//
//  TextFieldStyles.swift
//  SH4RE
//
//  Created by Americo on 2023-01-24.
//

import SwiftUI

struct textInputStyle: TextFieldStyle{
    //Making an optional error variable
    var error: Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            // Text alignment.
            .multilineTextAlignment(.leading)
            // Cursor color.
            .accentColor(error ? .red : .primaryDark)
            // Text color.
            .foregroundColor(error ? .red : .black)
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
            error ? .red : .gray,
          lineWidth: 1
        )
    }
}

/// This style expects a button with an image as the label to place at the beginning of the tet field
struct locationInputStyle: TextFieldStyle{
    
    var button: Button<Image>

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            button
            configuration
                .textFieldStyle(PlainTextFieldStyle())
            // Text alignment.
                .multilineTextAlignment(.leading)
            // Cursor color.
                .accentColor(.primaryDark)
            // Text color.
                .foregroundColor(.black)
                .padding(.leading, 5)
        }
        // TextField spacing.
        .padding(.vertical, 16)
        .padding(.leading, 16)
        .padding(.trailing, 20)
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
    var error: Bool = true
    var body: some View {
        VStack {
            TextField("Your email", text: $username)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(textInputStyle())
            TextField("Your error", text: $username)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(textInputStyle(error: error))
            TextField("Location", text: $username)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(
                    locationInputStyle(button: Button(action:{},
                                                      label:{
                                                          Image(systemName: "scope")
                                                      }))
                )
        }
    }
}

struct TextFieldStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldStyles_PreviewsHelper()
    }
}