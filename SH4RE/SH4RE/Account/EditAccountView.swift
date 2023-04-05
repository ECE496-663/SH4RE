//
//  EditAccountView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI
import FirebaseStorage
import Firebase

struct EditAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var user:User = User()
    @State private var profilePicture = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var showPhotoLibSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var pfpChanged: Bool = false
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var errorInField: Bool = false
    @State private var showPosted: Bool = false
    @State private var dataToChange:Dictionary<String, Any> = [String: Any]()
    
    func update() {
        
        let docRef = Firestore.firestore().collection("User Info").document(getCurrentUserUid())
        
        if(name == ""){
            errorInField.toggle()
            return
        }
        
        if(password.isEmpty && newPassword.isEmpty){
            if (name != user.name) {
                _ = documentUpdate(collectionPath: "User Info", documentID: getCurrentUserUid(), data: ["name": name])
            }
            if (pfpChanged) {
                let imgPath = "profilepictures/" + docRef.documentID + "/profile.jpg"
                let storageManager = StorageManager()
                storageManager.upload(image: profilePicture, path: imgPath)
                _ = documentUpdate(collectionPath: "User Info", documentID: docRef.documentID, data: ["pfp_path" : imgPath])
            }
            showPosted.toggle()
        }else{
            if (!password.isEmpty && !newPassword.isEmpty) {
                getCurrentUser(completion: {  user in
                    let credential = EmailAuthProvider.credential(withEmail: user.email, password: password)
                    Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (authResult, error) in
                    //TODO Proper error messages
                    if (error != nil) {
                        errorInField.toggle()
                        return
                    } else {
                        Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                            if (error != nil){
                                errorInField.toggle()
                                return
                            }else{
                                if (name != user.name) {
                                    _ = documentUpdate(collectionPath: "User Info", documentID: getCurrentUserUid(), data: ["name": name])
                                }
                                if (pfpChanged) {
                                    let imgPath = "profilepictures/" + docRef.documentID + "/profile.jpg"
                                    let storageManager = StorageManager()
                                    storageManager.upload(image: profilePicture, path: imgPath)
                                    _ = documentUpdate(collectionPath: "User Info", documentID: docRef.documentID, data: ["pfp_path" : imgPath])
                                }
                                showPosted.toggle()
                            }
                        }
                        
                    }
                  })
                })
            }else{
                errorInField.toggle()
                return
            }
        }

    }
    
    private var fields: some View {
        Group {
            Text("Name")
                .font(.system(size: 18))
                .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
            TextField("Your Name", text: $name)
                .disableAutocorrection(true)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(textInputStyle())
                .padding(.bottom)
            Text("Old Password")
                .font(.system(size: 18))
                .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
            SecureField("Your password", text: $password)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(textInputStyle())
                .padding(.bottom)
            Text("New Password")
                .font(.system(size: 18))
                .frame(maxWidth: screenSize.width * 0.8, alignment: .leading)
            SecureField("Your password", text: $newPassword)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .frame(width: screenSize.width * 0.8)
                .textFieldStyle(textInputStyle())
                .padding(.bottom)
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            VStack {
                Menu {
                    Button("Camera", action: {
                        showCameraSheet.toggle()
                        pfpChanged.toggle()
                    })
                    Button("Photo Library", action: {
                        showPhotoLibSheet.toggle()
                        pfpChanged.toggle()
                    })
                } label: {
                    VStack {
                        Image(uiImage: profilePicture)
                            .resizable()
                            .clipShape(Circle())
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenSize.width * 0.1, height: screenSize.height * 0.1)
                        Image(systemName: "camera.fill")
                            .foregroundColor(.primaryDark)
                    }
                }
                .sheet(isPresented: $showPhotoLibSheet) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $profilePicture)
                }
                .sheet(isPresented: $showCameraSheet) {
                    ImagePicker(sourceType: .camera, selectedImage: $profilePicture)
                }
                
                fields
                
                Spacer()
                
                // Post button
                Button(action: {
                    update()
                }) {
                    Text("Update")
                }
                .buttonStyle(primaryButtonStyle())

                // Cancel button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                {
                    Text("Cancel")
                }
                .buttonStyle(secondaryButtonStyle())
                .padding(.bottom)
            }
            PopUp(show: $showPosted) {
                VStack {
                    Text("Profile Updated!")
                        .foregroundColor(.primaryDark)
                        .bold()
                        .padding(.bottom)
                    Button(action: {
                        showPosted.toggle()
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    {
                        Text("OK")
                    }
                    .buttonStyle(primaryButtonStyle())
                }
                .padding()
                .frame(width: screenSize.width * 0.9, height: 130)
                .background(.white)
                .cornerRadius(30)
            }
            PopUp(show: $errorInField) {
                VStack {
                    Text("Nothing has been updated")
                        .foregroundColor(.errorColour)
                        .bold()
                        .padding(.bottom)
                    Button(action: {
                        errorInField.toggle()
                    })
                    {
                        Text("OK")
                    }
                    .buttonStyle(primaryButtonStyle())
                }
                .padding()
                .frame(width: screenSize.width * 0.9, height: 130)
                .background(.white)
                .cornerRadius(30)
            }
        }
        .navigationTitle("Edit Account")
        .onAppear() {
            getCurrentUser(completion: { result in
                user = result
                name = result.name
                let storageRef = Storage.storage().reference(withPath: result.pfpPath)
                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                    if let error = error {
                        print (error)
                    } else {
                        profilePicture = UIImage(data: data!) ?? UIImage(named: "ProfilePhotoPlaceholder")!
                    }
                }
            })
        }
    }
}
