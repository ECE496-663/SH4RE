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
    @State private var pictures:[UIImage] = []
    @State private var num_of_images = 1
    @State private var showSheet = false
    @State private var show_cal = false
    @State private var title: String = ""
    @State var drop_down_selection = ""
    var drop_down_placeholder = " Category"
    var drop_down_list = ["Tools", "Sporting Equipment", "Cameras", "Cooking"]
    @State var availability_dropdown_selection = ""
    var availability_dropdown_placeholder = " Availability"
    var availability_dropdown = ["Everyday", "Weekdays", "Weekends"]
    @State private var description_placeholder: String = "Description"
    @State private var description: String = ""
    @State var cost = ""
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @State private var dates: Set<DateComponents> = []
    var bounds: PartialRangeFrom<Date> {
            let start = calendar.date(
                from: DateComponents(
                    timeZone: timeZone,
                    year: Calendar.current.component(.year, from: Date()),
                    month: Calendar.current.component(.month, from: Date()),
                    day: Calendar.current.component(.day, from: Date()))
            )!
            return start...
        }

    let screenSize: CGRect = UIScreen.main.bounds
    var storageManager = StorageManager()
    var body: some View {
        ZStack {
            Color.init(UIColor(named: "Grey")!).ignoresSafeArea()
            VStack {
                // image picker
                GeometryReader { geometry in
                    ImageCarouselView(numberOfImages: self.num_of_images) {
                        ForEach(0..<pictures.count, id:\.self) { imageIdx in
                            Image(uiImage: pictures[imageIdx])
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: 250)
                                .aspectRatio(contentMode: .fill)
                        }
                        if (self.num_of_images < 6) {
                            Image("CreateListingBkgPic")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: 250)
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    showSheet = true
                                    if (!showSheet) {
                                        pictures.append(self.image)
                                    }
                                }
                                .onChange(of: self.image) { newItem in
                                    Task {
                                        pictures.append(self.image)
                                    }
                                    self.num_of_images += 1
                                }
                        }
                    }
                }
                // this just opens the sheet to select a photo from library
                .sheet(isPresented: $showSheet) {
                    // Pick an image from the photo library:
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                    
                    //  If you wish to take a photo from camera instead:
                    // ImagePicker(sourceType: .camera, selectedImage: self.$image)
                }
                .frame(maxHeight: 300)
                
                //divider
                Color.gray.frame(width: screenSize.width * 0.95, height: 1 / UIScreen.main.scale)
                
                ScrollView([.vertical]) {
                    // title entry
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: screenSize.width * 0.9, height: 20)
                        .padding()

                    // category entry
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

                    // description entry
                    TextEditorWithPlaceholder(text: $description)

                    // cost per day entry
                    TextField("Cost per day", text: $cost)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onReceive(Just(cost)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.cost = filtered
                            }
                        }
                        .frame(width: screenSize.width * 0.9, height: 20)
                        .padding()

                    Text("Availability")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: screenSize.width * 0.9, alignment: .leading)
                        .padding(.bottom)

                    // availability
                    Menu {
                        ForEach(availability_dropdown, id: \.self){ client in
                            Button(client) {
                                show_cal = false
                                dates = []
                                self.availability_dropdown_selection = " "+client
                            }
                        }
                    } label: {
                        VStack{
                            HStack{
                                Text(availability_dropdown_selection.isEmpty ? availability_dropdown_placeholder : availability_dropdown_selection)
                                    .foregroundColor(availability_dropdown_selection.isEmpty ? Color.init(UIColor(named: "TextFieldInputDefault")!) : .black)
                                Spacer()
                                Image(systemName: "arrowtriangle.left.fill")
                                    .foregroundColor(Color.init(UIColor(named: "DarkGrey")!))
                            }
                            .frame(width: screenSize.width * 0.9, height: 30)
                            .background(.white)
                            .cornerRadius(5)
                        }
                    }
                    HStack {
                        Text("or make a")
                        Button(action: {
                            show_cal = true
                            availability_dropdown_selection = ""
                        }) {
                            Text("Custom Availability")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.init(UIColor(named: "PrimaryBase")!))
                    }
                    .frame(maxWidth: screenSize.width * 0.85, alignment: .leading)

                    // custom availability calendar
                    if (show_cal) {
                        MultiDatePicker(
                            "Start Date",
                            selection: $dates,
                            in: bounds
                        )
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: screenSize.width * 0.9)
                    }

                    // POST
                    Button(action: {
                        // upload data fields
                        var cal_avail = ""
                        if (show_cal) {
                            var string_dates = ""
                            for date in dates {
                                let res = String(date.year!) + "-" + String(date.month!) + "-" + String(date.day!)
                                string_dates += res + ","
                            }
                            cal_avail = String(string_dates.dropLast())
                        }
                        else {
                            cal_avail = availability_dropdown_selection
                        }
                        let listing_fields = ["Title": title, "Description" : description, "Price" : cost, "Category" : drop_down_selection, "Availability": cal_avail]
                        let document_id = documentWrite(collectionPath: "Listings",data:listing_fields)

                        // upload images and add paths to data fields
                        var i = 1
                        var image_path = ""
                        var arr_imgs:[String] = []
                        for pic in pictures {
                            image_path = "listingimages/" + document_id + "/" + String(i) + ".jpg"
                            arr_imgs.append(image_path)
                            storageManager.upload(image: pic, path: image_path)
                            i += 1
                        }
                        if (documentUpdate(collectionPath: "Listings", documentID: document_id, data: ["image_path" : arr_imgs])) {
                            NSLog("error");
                        }

                        //reset inputs
                        self.pictures = []
                        self.num_of_images = 1
                        self.title = ""
                        self.description = ""
                        self.cost = ""
                        self.drop_down_selection = ""
                        self.availability_dropdown_selection = ""
                        show_cal = false
                    }) {
                        Text("Post")
                            .fontWeight(.semibold)
                            .frame(width: screenSize.width * 0.9, height: 20)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.init(UIColor(named: "PrimaryDark")!))
                            .cornerRadius(40)
                    }

                    // Cancel
                    Button(action: {
                        self.pictures = []
                        self.num_of_images = 1
                        self.title = ""
                        self.description = ""
                        self.cost = ""
                        self.drop_down_selection = ""
                        self.availability_dropdown_selection = ""
                        show_cal = false
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .frame(width: screenSize.width * 0.9, height: 10)
                            .padding()
                            .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                            .background(.white)
                            .cornerRadius(40)
                            .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.init(UIColor(named: "PrimaryDark")!), lineWidth: 2))
                    }
                    .padding(.bottom)
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

struct ImageCarouselView<Content: View>: View {
    private var numberOfImages: Int
    private var content: Content
    @State private var currentIndex: Int = 0
    @State private var offset = CGSize.zero

    init(numberOfImages: Int, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    self.content
                }
                .frame(width: geometry.size.width, height: 300, alignment: .leading)
                .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
                .animation(.spring())
                .onChange(of: self.numberOfImages) { newItem in
                    Task {
                        self.currentIndex = (self.numberOfImages == 6) ? 0 : self.currentIndex
                        self.currentIndex = (self.numberOfImages - self.currentIndex != 1) ? 0 : self.currentIndex
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            if offset.width > 20 {
                                if self.currentIndex > 0 {
                                    self.currentIndex -= 1
                                }
                            }
                            else if offset.width < 20 {
                                if self.currentIndex < numberOfImages - 1 && self.currentIndex < 4 {
                                    self.currentIndex += 1
                                }
                            }
                            else {
                                offset = .zero
                            }
                        }
                )
                HStack(spacing: 3) {
                    let scroll_offset = (numberOfImages == 6) ? 1 : 0
                    ForEach(0..<self.numberOfImages - scroll_offset, id: \.self) { index in
                        Capsule()
                            .frame(width: index == self.currentIndex ? 50 : 10, height: 10)
                            .foregroundColor(index == self.currentIndex ? Color.init(UIColor(named: "PrimaryDark")!) : .white)
                            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                            .padding(.bottom, 8)
                            .animation(.spring())
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }
}
