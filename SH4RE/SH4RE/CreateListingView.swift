//
//  CreateListingView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI
import Combine

struct CreateListingView: View {
    @State private var image = UIImage(named: "CreateListingBkgPic")!
    @State private var showSheet = false
    @State private var title: String = ""
    @State var drop_down_selection = ""
    var drop_down_placeholder = " Category"
    var drop_down_list = ["Tools", "Sporting Equipment", "Cameras", "Cooking"]
    @State private var description_placeholder: String = "Description"
    @State private var description: String = ""
    @State var cost = ""
    let screenSize: CGRect = UIScreen.main.bounds
    var storageManager = StorageManager()
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            VStack {
                Text("Create a new listing")
                
                HStack {
                    Image(uiImage: self.image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(width: screenSize.width * 0.9, height: 250)
                        .aspectRatio(contentMode: .fill)
                        .onTapGesture {
                            showSheet = true
                        }
                }
                .sheet(isPresented: $showSheet) {
                    // Pick an image from the photo library:
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                    
                    //  If you wish to take a photo from camera instead:
                    // ImagePicker(sourceType: .camera, selectedImage: self.$image)
                }
                
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: screenSize.width * 0.9, height: 20)
                    .padding()
                
                Menu {
                    ForEach(drop_down_list, id: \.self){ client in
                        Button(client) {
                            self.drop_down_selection = " "+client
                        }
                    }
                } label: {
                    VStack{
                        HStack{
                            Text(drop_down_selection.isEmpty ? drop_down_placeholder : drop_down_selection)
                                .foregroundColor(drop_down_selection.isEmpty ? Color.init(UIColor(named: "TextFieldInputDefault")!) : .black)
                            Spacer()
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundColor(Color.init(UIColor(named: "DarkGrey")!))
                        }
                        .frame(width: screenSize.width * 0.9, height: 30)
                        .background(.white)
                        .cornerRadius(5)
                    }
                }
                
                TextEditorWithPlaceholder(text: $description)
                
                TextField("Cost per day", text: $cost)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onReceive(Just(cost)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.cost = "$"+filtered
                        }
                    }
                    .frame(width: screenSize.width * 0.9, height: 20)
                    .padding()
                
                Button(action: {
                    var listing_fields = ["Title": title, "Description" : description, "Price" : cost, "Category" : drop_down_selection]
                    let document_id = documentWrite(collectionPath: "Listings",data:listing_fields)
                    //TODO : increment images when we add ability to upload multiple
                    let image_path = "listingimages/" + document_id + "/1.jpg"
                    storageManager.upload(image: image, path: image_path)
                    //setting image path of just uploaded image
                    documentUpdate(collectionPath: "Listings", documentID: document_id, data: ["image_path" : image_path])
                }) {
                    Text("Post")
                        .fontWeight(.semibold)
                        .frame(width: screenSize.width * 0.9, height: 20)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.init(UIColor(named: "PrimaryDark")!))
                        .cornerRadius(40)
                }
            }
        }
    }
}

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    let screenSize: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                VStack {
                    Text("Description")
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .opacity(1)
                        .foregroundColor(.black)
                        .padding()
                }
            }

            VStack {
                TextEditor(text: $text)
                    .frame(width: screenSize.width * 0.9, height: 100)
                    .opacity(text.isEmpty ? 0.85 : 1)
                    .cornerRadius(5)
                    .padding()
            }
        }
    }
}
