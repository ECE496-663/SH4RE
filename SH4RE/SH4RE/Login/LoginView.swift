//
//  LoginPage.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI
import FirebaseAuth
import AlertX

struct LoginView: View {
    @Environment(\.showCreateAccountScreen) var showCreateAccountScreen
    @EnvironmentObject var currentUser : CurrentUser
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorInField: Bool = false
    @State private var errorDescription: String = ""

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
                        if (username.isEmpty || password.isEmpty) {
                            errorInField = true
                            errorDescription = "Some entries missing"
                        }
                        else {
                            Task {
                                do {
                                    try await Auth.auth().signIn(withEmail: username, password: password)
                                    currentUser.hasLoggedIn = true
                                }
                                catch {
                                    errorInField = true
                                    errorDescription = "Username and password did not match"
                                }
                            }
                        }
                    })
                    {
                        Text("Login")
                            .fontWeight(.bold)
                            .frame(width: screenSize.width * 0.8, height: 40)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.primaryDark)
                            .cornerRadius(40)
                            .padding(.bottom)
                    }
                    .alertX(isPresented: $errorInField, content: {
                        AlertX(
                            title: Text("ERROR: " + errorDescription),
                            theme: AlertX.Theme.custom(
                                windowColor: .grey,
                                alertTextColor: .errorColour,
                                enableShadow: true,
                                enableRoundedCorners: true,
                                enableTransparency: false,
                                cancelButtonColor: .white,
                                cancelButtonTextColor: .white,
                                defaultButtonColor: .primaryDark,
                                defaultButtonTextColor: .white
                            )
                        )
                    })
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
                        Task{
                            do  {
                              try await Auth.auth().signInAnonymously()
                              currentUser.hasLoggedIn = true
                            }
                            catch {
                              print(error.localizedDescription)
                            }
                        }
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
