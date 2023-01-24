//
//  CreateAccount.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.showLoginScreen) var showLoginScreen
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        ZStack {
            Color(UIColor(.primaryBase))
                .ignoresSafeArea()
            VStack {
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .padding(.top, 70)
                    .padding(.bottom, 40)
                
                VStack (alignment: .trailing) {
                    Spacer()
                        .frame(height: screenSize.height * 0.05)
                    
                    VStack {
                        Text("Email Address")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        TextField("Your email", text: $username)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8)
                            .textFieldStyle(textInputStyle())
                            .padding(.bottom)
                        
                        Text("Password")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        SecureField("Your password", text: $password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8)
                            .textFieldStyle(textInputStyle())
                            .padding(.bottom)
                        
                        
                        Text("Confirm Password")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        SecureField("Your password", text: $confirmPassword)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8)
                            .textFieldStyle(textInputStyle())
                    }
                    
                    Spacer()
                    
                    VStack (alignment: .trailing) {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set("test", forKey: "UID")
                        })
                        {
                            Text("Create Account")
                        }
                        .buttonStyle(primaryButtonStyle())
                        Button(action: {
                            showLoginScreen!()
                        })
                        {
                            Text("Cancel")
                        }
                        .buttonStyle(secondaryButtonStyle())
                    }
                    .padding(.bottom, 50)
                }
                .frame(maxWidth: screenSize.width)
                .background(Color.grey)
                .cornerRadius(50)
            }
        }
        .frame(height: screenSize.height)
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
