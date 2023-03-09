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
                        Text("Name")
                            .font(.system(size: 18))
                            .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                        TextField("Your Name", text: $name)
                            .disableAutocorrection(true)
                            .frame(width: screenSize.width * 0.8)
                            .textFieldStyle(textInputStyle())
                            .padding(.bottom)
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
                        .buttonStyle(primaryButtonStyle())
                        Button(action: {
                            showLoginScreen!()
                        })
                        {
                            Text("Cancel")
                        }
                        .buttonStyle(secondaryButtonStyle())
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
