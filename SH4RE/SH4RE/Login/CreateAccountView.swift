//
//  CreateAccount.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI
import FirebaseAuth
import AlertX

struct CreateAccountView: View {
    @Environment(\.showLoginScreen) var showLoginScreen
    @EnvironmentObject var currentUser : CurrentUser
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorInField: Bool = false
    @State private var errorDescription: String = ""

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
                        Text("Name")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        TextField("Your Name", text: $name)
                            .disableAutocorrection(true)
                            .frame(width: screenSize.width * 0.8, height: 20)
                            .textFieldStyle(.roundedBorder)
                            .padding()
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
                        .frame(height: screenSize.height * 0.1)
                    
                    VStack {
                        Button(action: {
                            if (username.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                                errorInField = true
                                errorDescription = "Some entries missing"
                            }
                            else if (password != confirmPassword) {
                                errorInField = true
                                errorDescription = "Passwords did not match"
                            }
                            else {
                                Task {
                                    do {
                                        try await Auth.auth().createUser(withEmail: username, password: password)
                                        currentUser.hasLoggedIn = true
                                        documentWrite(collectionPath: "User Info", uid: Auth.auth().currentUser!.uid, data: ["name": name,"email": username])
                                    }
                                    catch {
                                        errorInField = true
                                        errorDescription = error.localizedDescription
                                    }
                                }
                            }
                        })
                        {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .frame(width: screenSize.width * 0.8, height: 40)
                                .foregroundColor(.white)
                                .background(Color.primaryDark)
                                .cornerRadius(40)
                        }
                        .alertX(isPresented: $errorInField, content: {
                            AlertX(
                                title: Text("ERROR: " + errorDescription),
                                theme: AlertX.Theme.custom(
                                    windowColor: .errorColour,
                                    alertTextColor: .white,
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
                                .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.primaryDark, lineWidth: 2))
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
