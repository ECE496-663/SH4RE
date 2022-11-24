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
    
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
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
                                .foregroundColor(drop_down_selection.isEmpty ? Color("TextGrey") : Color("Black"))
                            Spacer()
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundColor(Color("TextGrey"))
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
                    print("Post tapped!")
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
