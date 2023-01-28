//
//  LoginPage.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.showCreateAccountScreen) var showCreateAccountScreen
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color(UIColor(.primaryBase))
                .ignoresSafeArea()
            Text("Login")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .position(x: screenSize.width * 0.5, y: screenSize.height * 0.05)

            Group {
                VStack {
                    Spacer()
                        .frame(height: screenSize.height * 0.05)
                    Group {
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
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        })
                        {
                            Text("Forgot Password?\t\t")
                                .font(.system(size: 15))
                                .frame(alignment: .trailing)
                                .foregroundColor(.primaryBase)
                            
                        }
                    }

                    Spacer()
                        .frame(height: screenSize.height * 0.25)

                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set("test", forKey: "UID")
                    })
                    {
                        Text("Login")
                    }
                    .buttonStyle(primaryButtonStyle(tall:true))
                    .padding(.bottom)
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Button(action: {
                            showCreateAccountScreen!()
                        })
                        {
                            Text("Create a new account")
                                .font(.system(size: 15))
                                .frame(alignment: .trailing)
                                .foregroundColor(.primaryDark)
                        }
                    }
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    })
                    {
                        Text("Or continue as guest")
                            .font(.system(size: 15))
                            .frame(alignment: .trailing)
                            .foregroundColor(.primaryDark)
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

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
