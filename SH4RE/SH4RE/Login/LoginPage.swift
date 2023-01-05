//
//  LoginPage.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct LoginPage: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        let screenSize: CGRect = UIScreen.main.bounds
        ZStack {
            Color(UIColor(Color.init(UIColor(named: "PrimaryBase")!)))
                .ignoresSafeArea()
            Text("Login")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .position(x: screenSize.width * 0.5, y: screenSize.height * 0.05)

            Group {
                VStack {
                    Spacer()
                        .frame(height: screenSize.height * 0.05)
                    Text("Email Address")
                        .font(.system(size: 18))
                        .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                    TextField("Your email", text: $username)
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

                    HStack {
                        Spacer()
                        Button(action: {
                            
                        })
                        {
                            Text("Forgot Password?\t\t")
                                .font(.system(size: 15))
                                .frame(alignment: .trailing)
                                .foregroundColor(Color.init(UIColor(named: "PrimaryBase")!))
                            
                        }
                    }

                    Spacer()
                        .frame(height: screenSize.height * 0.25)

                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    })
                    {
                        Text("Login")
                            .fontWeight(.bold)
                            .frame(width: screenSize.width * 0.8, height: 40)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.init(UIColor(named: "PrimaryDark")!))
                            .cornerRadius(40)
                            .padding(.bottom)
                    }
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Button(action: {
                            
                        })
                        {
                            Text("Create a new account")
                                .font(.system(size: 15))
                                .frame(alignment: .trailing)
                                .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: screenSize.width, maxHeight: screenSize.height)
                .background(Color.init(UIColor(named: "Grey")!))
                .cornerRadius(50)
            }
            .offset(x: 0, y: screenSize.height * 0.15)
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
