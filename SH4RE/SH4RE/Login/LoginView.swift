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
    @State private var showForgotPasswordPopUp: Bool = false
    @State private var email: String = ""


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
                            showForgotPasswordPopUp.toggle()
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
            
            forgotPasswordPopUp
        }
        
    }
    
    private var forgotPasswordPopUp: some View {
        PopUp(show: $showForgotPasswordPopUp) {
            VStack {
                Text("Please enter your email.")
                    .bold()
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryDark)
                
                Text("If an account exists with this email, you will recieve an email to reset your password shortly.")
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryDark)
                
                TextField("Email", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .frame(width: screenSize.width * 0.8)
                    .textFieldStyle(textInputStyle())
                    .padding(.bottom)
                
                Button(action: {
                    sendForgotPasswordEmail(email: email)
                    showForgotPasswordPopUp.toggle()
                })
                {
                    Text("Send")
                }
                .buttonStyle(primaryButtonStyle())
                Button(action: {
                    showForgotPasswordPopUp.toggle()
                })
                {
                    Text("Cancel")
                }
                .buttonStyle(secondaryButtonStyle())
            }
            .padding()
            .frame(width: screenSize.width * 0.9, height: 350)
            .background(.white)
            .cornerRadius(30)
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
