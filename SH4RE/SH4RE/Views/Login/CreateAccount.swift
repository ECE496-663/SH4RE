//
//  CreateAccount.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI
import FirebaseAuth

struct CreateAccount: View {
    @Environment(\.showLoginScreen) var showLoginScreen
    @EnvironmentObject var currentUser : CurrentUser
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        ZStack {
            Color(UIColor(Color.init(UIColor(named: "PrimaryBase")!)))
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
                            Task{
                                do  {
                                  try await Auth.auth().createUser(withEmail: username, password: password)
                                }
                                catch {
                                  print(error.localizedDescription)
                                }
                            }
                            currentUser.hasLoggedIn = true
                        })
                        {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .frame(width: screenSize.width * 0.8, height: 40)
                                .foregroundColor(.white)
                                .background(Color.init(UIColor(named: "PrimaryDark")!))
                                .cornerRadius(40)
                        }
                        Button(action: {
                            self.showLoginScreen!()
                        })
                        {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.8, height: 40)
                                .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                                .background(.white)
                                .cornerRadius(40)
                                .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.init(UIColor(named: "PrimaryDark")!), lineWidth: 2))
                        }
                        Button(action: {
                            Task{
                                do  {
                                  try await Auth.auth().signInAnonymously()
                                }
                                catch {
                                  print(error.localizedDescription)
                                }
                            }
                            currentUser.hasLoggedIn = true
                        })
                        {
                            Text("Continue as guest")
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

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount()
    }
}
