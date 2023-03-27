//
//  EditAccountView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI
import FirebaseStorage

struct EditAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var user:User = User()
    @State private var profilePicture = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var showPhotoLibSheet: Bool = false
    @State private var showCameraSheet: Bool = false
    @State private var pfpChanged: Bool = false
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorInField: Bool = false
    @State private var showPosted: Bool = false
    @State private var dataToChange:Dictionary<String, Any> = [String: Any]()
    
    func update() {
        dataToChange.removeAll()
        if (name != user.name && name != "") {
            dataToChange["name"] = name
        }
        if (pfpChanged) {
            dataToChange["pfp"] = profilePicture
        }
        if (!password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword) {
            dataToChange["pwd"] = password
        }
        if (dataToChange.count == 0) {
            errorInField.toggle()
            return
        }
        // bryan TODO: update user fields
        showPosted.toggle()
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
                        .fontWeight(.semibold)
                        .frame(width: screenSize.width * 0.8, height: 20)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.primaryDark)
                        .cornerRadius(40)
                }
                
                // Cancel button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(width: screenSize.width * 0.8, height: 10)
                        .padding()
                        .foregroundColor(.primaryDark)
                        .background(.white)
                        .cornerRadius(40)
                        .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.primaryDark, lineWidth: 2))
                }
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
