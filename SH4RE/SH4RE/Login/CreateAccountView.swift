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
    var storageManager = StorageManager()
    @State private var profilePicture = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorInField: Bool = false
    @State private var errorDescription: String = ""
    @State private var showPhotoLibSheet: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor(.primaryBase))
                    .ignoresSafeArea()
                VStack {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .padding(.bottom, 40)
                    ScrollView (.vertical, showsIndicators: false) {
                        VStack (alignment: .trailing) {
                            Spacer()
                                .frame(height: screenSize.height * 0.01)
                            VStack {
                                Button(action: {showPhotoLibSheet.toggle()}
                                ){
                                    VStack {
                                        Image(uiImage: profilePicture)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: screenSize.width * 0.2, height: screenSize.width * 0.2)
                                            .clipShape(Circle())
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.primaryDark)
                                    }
                                }
                                .sheet(isPresented: $showPhotoLibSheet) {
                                    ImagePicker(sourceType: .photoLibrary, selectedImage: $profilePicture)
                                }
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
                                    .textContentType(.oneTimeCode)
                                
                                Text("Confirm Password")
                                    .font(.system(size: 18))
                                    .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
                                SecureField("Your password", text: $confirmPassword)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                    .frame(width: screenSize.width * 0.8)
                                    .textFieldStyle(textInputStyle())
                                    .padding(.bottom)
                                    .textContentType(.oneTimeCode)
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
                                                currentUser.sendVerificationEmail()
                                                
                                                let documentID = documentWrite(collectionPath: "User Info", uid: Auth.auth().currentUser!.uid, data: ["name": name,"email": username])
                                                
                                                // upload profile picture
                                                let imgPath = "profilepictures/" + documentID + "/profile.jpg"
                                                storageManager.upload(image: profilePicture, path: imgPath)
                                                if (documentUpdate(collectionPath: "User Info", documentID: documentID, data: ["pfp_path" : imgPath])) {
                                                    NSLog("error");
                                                }
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
                            }
                            .padding(.bottom, 50)
                        }
                    }
                    .frame(maxWidth: screenSize.width)
                    .background(Color.grey)
                    .cornerRadius(50)
                }
            }
            .frame(height: screenSize.height)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
