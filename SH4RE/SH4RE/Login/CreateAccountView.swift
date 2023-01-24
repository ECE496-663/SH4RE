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
            Text("Create Account")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .position(x: screenSize.width * 0.5, y: screenSize.height * 0.05)

            Group {
                VStack {
                    Spacer()
                        .frame(height: screenSize.height * 0.05)
                    
                    VStack {
                        Text("Email Address")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        TextField("Your email", text: $username)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8, height: 20)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                        Text("Password")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        SecureField("Your password", text: $password)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8, height: 20)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                        Text("Confirm Password")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        SecureField("Your password", text: $confirmPassword)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(width: screenSize.width * 0.8, height: 20)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                    }

                    Spacer()
                        .frame(height: screenSize.height * 0.25)
                    
                    VStack {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set("test", forKey: "UID")
                        })
                        {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .frame(width: screenSize.width * 0.8, height: 40)
                                .foregroundColor(.white)
                                .background(Color.primaryDark)
                                .cornerRadius(40)
                        }
                        Button(action: {
                            showLoginScreen!()
                        })
                        {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.8, height: 40)
                                .foregroundColor(.primaryDark)
                                .background(.white)
                                .cornerRadius(40)
                                .overlay(RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.primaryDark, lineWidth: 2))
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: screenSize.width, maxHeight: screenSize.height)
                .background(Color.grey)
                .cornerRadius(50)
            }
            .offset(x: 0, y: screenSize.height * 0.15)
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
