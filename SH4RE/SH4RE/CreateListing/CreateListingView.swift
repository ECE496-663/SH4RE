//
//  CreateListingView.swift
//  SH4RE
//
//  Created by November on 2022-11-18.
//

import Foundation
import SwiftUI
import Combine
import AlertX
import FirebaseAuth

struct ParentFunctionKey: EnvironmentKey {
    static let defaultValue: ((Int) -> Void)? = nil
}
extension EnvironmentValues {
    var deleteImage: ((Int) -> Void)? {
        get { self[ParentFunctionKey.self] }
        set { self[ParentFunctionKey.self] = newValue }
    }
}

struct CreateListingView: View {
    var storageManager = StorageManager()
    @Binding var tabSelection: Int
    @State private var image = UIImage(named: "CreateListingBkgPic")!
    @State private var pictures:[UIImage] = []
    @State private var imagesCount = 1
    @State private var showSheet = false
    func deleteImage (index: Int) {
        imagesCount -= 1
        pictures.remove(at: index)
    }
    
    // text fields
    @State private var title: String = ""
    @State private var postalCode: String = ""
    @State var cost = ""
    @State private var description: String = ""

    // drop down fields
    @State var categorySelection = ""
    var categoryPlaceholder = " Category"
    var categoryList = ["Tools", "Sporting Equipment", "Cameras", "Cooking"]
    @State var availabilitySelection = ""
    var availabilityPlaceholder = " Availability"
    var availabilityList = ["Everyday", "Weekdays", "Weekends"]
    
    // calendar entry
    @State private var showCal = false
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @State private var dates: Set<DateComponents> = []
    @EnvironmentObject var currentUser: CurrentUser
    
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
    
    // popups
    @State var showPostAlertX: Bool = false
    @State var showCancelAlertX: Bool = false
    @State var errorInField: Bool = false
    
    // componnents
    private var imageView: some View {
        Group {
            GeometryReader { geometry in
                ImageCarouselView(numberOfImages: imagesCount, isEditable: true) {
                    ForEach(pictures, id:\.self) { picture in
                        HStack {
                            Image(uiImage: picture)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width * 0.9, height: 250)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primaryDark, lineWidth: 3))
                                .shadow(radius: 10)
                            
                        }
                        .frame(width: geometry.size.width, height: 250)
                    }
                    if (imagesCount < 6) {
                        HStack {
                            Image("CreateListingBkgPic")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width * 0.9, height: 250)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primaryDark, lineWidth: 3))
                                .onTapGesture {
                                    showSheet = true
                                    if (!showSheet) {
                                        pictures.append(image)
                                    }
                                }
                                .onChange(of: image) { newItem in
                                    Task {
                                        pictures.append(image)
                                    }
                                    imagesCount += 1
                                }
                        }
                        .frame(width: geometry.size.width, height: 250)
                    }
                }
            }
            .environment(\.deleteImage, deleteImage)
            .sheet(isPresented: $showSheet) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            }
            .frame(height: 275)
            
            //divider
            Color.gray
                .frame(width: screenSize.width * 0.95, height: 1 / UIScreen.main.scale)
                .padding(.top)
        }
    }
    private var fieldEntriesView: some View {
        Group {
            // title entry
            TextField("Title", text: $title)
                .textFieldStyle(textInputStyle())
                .frame(width: screenSize.width * 0.9)
                .padding()
            
            // category entry
            DropdownMenu(label: "Category", options: categoryList, selection: $categorySelection)
                .frame(maxWidth: screenSize.width * 0.9)
            
            // description entry
            TextField("Description", text: $description,  axis: .vertical)
                .lineLimit(5...10)
                .textFieldStyle(textInputStyle())
                .frame(width: screenSize.width * 0.9)
                .padding()
            
            // cost per day entry
            TextField("Cost per day", text: $cost)
                .textFieldStyle(textInputStyle())
                .keyboardType(.numberPad)
                .onReceive(Just(cost)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        cost = filtered
                    }
                }
                .frame(width: screenSize.width * 0.9)
                .padding()
            
            // postal code entry
            TextField("Postal Code e.g. A1A 1A1", text: $postalCode)
                .textFieldStyle(textInputStyle())
                .frame(width: screenSize.width * 0.9)
                .padding()
        }
    }
    private var availabilityView: some View {
        Group {
            Text("Availability")
                .font(.title2)
                .frame(maxWidth: screenSize.width * 0.9, alignment: .leading)
                .padding(.bottom)
            
            // availability
            DropdownMenu(label: "Availability", options: availabilityList, selection: $availabilitySelection)
                .frame(maxWidth: screenSize.width * 0.9)
            
            HStack {
                Text("or make a")
                Button(action: {
                    showCal = true
                    availabilitySelection = ""
                }) {
                    Text("Custom Availability")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryBase)
            }
            .frame(maxWidth: screenSize.width * 0.85, alignment: .leading)
            
            // custom availability calendar
            PopUp(show: $showCal) {
                DatePicker(dates: dates)
            }
        }
    }
    func resetInputs () {
        pictures = []
        imagesCount = 1
        title = ""
        description = ""
        cost = ""
        postalCode = ""
        categorySelection = ""
        availabilitySelection = ""
        showCal = false
    }
    func validatePost () {
        if (title.isEmpty || cost.isEmpty || postalCode.isEmpty ||
            pictures.isEmpty || categorySelection.isEmpty || description.isEmpty ||
            (availabilitySelection.isEmpty && dates.isEmpty)) {
            errorInField = true
        }
        if (!errorInField) {
            // upload data fields
            var calAvail = ""
            if (showCal) {
                var stringDates = ""
                for date in dates {
                    let res = String(date.year!) + "-" + String(date.month!) + "-" + String(date.day!)
                    stringDates += res + ","
                }
                calAvail = String(stringDates.dropLast())
            }
            else {
                calAvail = availabilitySelection
            }
            let listingFields = ["Title": title, "Description" : description, "Price" : cost, "Category" : categorySelection, "Availability": calAvail, "Address": postalCode, "UID": getCurrentUserUid()]
            let documentID = documentWrite(collectionPath: "Listings", data: listingFields)
            
            // upload images and add paths to data fields
            var index = 1
            var imgPath = ""
            var arrayImgs:[String] = []
            for pic in pictures {
                imgPath = "listingimages/" + documentID + "/" + String(index) + ".jpg"
                arrayImgs.append(imgPath)
                storageManager.upload(image: pic, path: imgPath)
                index += 1
            }
            if (documentUpdate(collectionPath: "Listings", documentID: documentID, data: ["image_path" : arrayImgs])) {
                NSLog("error");
            }
            showPostAlertX = true

            //reset inputs
            resetInputs()
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else {
                ScrollViewReader { value in
                    ScrollView([.vertical]) {
                        Text("New Post")
                            .font(.title2)
                            .bold()
                            .id(1)
                        
                        imageView
                        
                        fieldEntriesView
                            
                        availabilityView
                        
                        // Post button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 1)) {
                                value.scrollTo(1)
                            }
                            // validate entries
                            validatePost()
                            
                        }) {
                            Text("Post")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.9, height: 20)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.primaryDark)
                                .cornerRadius(40)
                        }
                        
                        // Cancel button
                        Button(action: {
                            resetInputs()
                            showCancelAlertX.toggle()
                            withAnimation(.easeInOut(duration: 1)) {
                                value.scrollTo(1)
                            }
                        })
                        {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.9, height: 10)
                                .padding()
                                .foregroundColor(.primaryDark)
                                .background(.white)
                                .cornerRadius(40)
                                .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.primaryDark, lineWidth: 2))
                        }
                        .padding(.bottom)
                    }
                }
                PopUp(show: $errorInField) {
                    VStack {
                        Text("ERROR: Entries missing")
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
                PopUp(show: $showPostAlertX) {
                    VStack {
                        Text("Listing Posted!")
                            .foregroundColor(.primaryDark)
                            .bold()
                            .padding(.bottom)
                        Button(action: {
                            showPostAlertX.toggle()
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
                PopUp(show: $showCancelAlertX) {
                    VStack {
                        Text("Listing Cleared")
                            .foregroundColor(.primaryDark)
                            .bold()
                            .padding(.bottom)
                        Button(action: {
                            showCancelAlertX.toggle()
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
