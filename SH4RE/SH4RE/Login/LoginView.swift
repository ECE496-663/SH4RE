//
//  LoginPage.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.showCreateAccountScreen) var showCreateAccountScreen
    @EnvironmentObject var currentUser : CurrentUser
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
                        Task{
                            do  {
                              try await Auth.auth().signIn(withEmail: username, password: password)
                            }
                            catch {
                              print(error.localizedDescription)
                            }
                        }
                        currentUser.hasLoggedIn = true
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
                            }
                            catch {
                              print(error.localizedDescription)
                            }
                        }
                        currentUser.hasLoggedIn = true
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
