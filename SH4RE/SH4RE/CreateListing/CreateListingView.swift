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
import Firebase
import FirebaseAuth
import FirebaseStorage
import CoreLocation

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
    @Environment(\.presentationMode) var presentationMode
    @Binding var tabSelection: Int
    @Binding var editListing: Listing
    @State var isEditing:Bool = false
    var storageManager = StorageManager()
    
    // images
    @State private var image = UIImage(named: "CreateListingBkgPic")!
    @State private var pictures:[UIImage] = []
    @State private var imagesCount = 1
    @State private var showSheet = false
    @State private var picturesUnchanged = true
    func deleteImage (index: Int) {
        picturesUnchanged = false
        imagesCount -= 1
        pictures.remove(at: index)
    }
    
    // text fields
    @State private var title: String = ""
    @State private var postalCode: String = ""
    @State private var isPostalCodeValid:Bool = false
    @State private var lat:Double = 0.0
    @State private var lon:Double = 0.0
    @State var cost = ""
    @State private var description: String = ""

    // drop down fields
    @State var categorySelection = ""
    var categoryList = ["Film & Photography", "Audio Visual Equipment", "Projectors & Screens", "Drones", "DJ Equipment", "Transport", "Storage", "Electronics", "Party & Events", "Sports", "Musical Instruments", "Home, Office & Garden", "Holiday & Travel", "Clothing"]
    @State var availabilitySelection = ""
    var availabilityList = ["Everyday", "Weekdays", "Weekends"]
    
    // calendar entry
    @State private var showCal = false
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @State private var dates: Set<DateComponents> = []
    @State var availabilityCalendar = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*90), mode: 3)
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
    @State var shouldDisableUpdateButton: Bool = true
    
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
                                    picturesUnchanged = false
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
                .onReceive(Just(postalCode)) { address in
                    isPostalCodeValid = false
                    let range = NSRange(location: 0, length: postalCode.utf16.count)
                    let regex1 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z][0-9][A-Za-z][0-9]")
                    let res1 = regex1!.firstMatch(in: postalCode, options: [], range: range)
                    let regex2 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z]-[0-9][A-Za-z][0-9]")
                    let res2 = regex2!.firstMatch(in: postalCode, options: [], range: range)
                    let regex3 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z] [0-9][A-Za-z][0-9]")
                    let res3 = regex3!.firstMatch(in: postalCode, options: [], range: range)
                    if (res1 != nil || res2 != nil || res3 != nil) {
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString(address) { (placemarks, error) in
                            guard
                                let placemarks = placemarks,
                                let location = placemarks.first?.location
                            else {
                                // handle no location found
                                return
                            }
                            // Use your location
                            isPostalCodeValid = true
                            lat = location.coordinate.latitude
                            lon = location.coordinate.longitude
                        }
                    }
                }
        }
    }
    private var availabilityView: some View {
        Group {
            Text("Availability")
                .font(.title2)
                .frame(maxWidth: screenSize.width * 0.9, alignment: .leading)
                .padding(.bottom)
            
            // availability
            DropdownMenu(label: "Availability for the Next 3 Months", options: availabilityList, selection: $availabilitySelection)
                .frame(maxWidth: screenSize.width * 0.9)
                .onChange(of: availabilitySelection) { value in
                        availabilityCalendar.selectedDates = []
                    }
            
            HStack {
                Text("or set")
                Button(action: {
                    showCal = true
                    availabilitySelection = ""
                }) {
                    Text("Custom Unavailable Dates")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryBase)
            }
            .frame(maxWidth: screenSize.width * 0.85, alignment: .leading)
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
        availabilityCalendar.selectedDates = []
        showCal = false
    }
    func post() {
        var calAvail = [Any]()
        if (!availabilityCalendar.selectedDates.isEmpty) {
            for date in availabilityCalendar.selectedDates {
                calAvail.append(date)
            }
        }
        else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let startOfMonth = calendar.date(from:components)!
            let numberOfDays = calendar.range(of: .day, in: .quarter, for: startOfMonth)!.upperBound
            let allDays = Array(0..<numberOfDays).map{ calendar.date(byAdding:.day, value: $0, to: startOfMonth)!}
            if (availabilitySelection == "Everyday") {
                calAvail = []
            }
            else if (availabilitySelection == "Weekdays") {
                calAvail = allDays.filter{ calendar.isDateInWeekend($0) }
            }
            else if (availabilitySelection == "Weekends") {
                calAvail = allDays.filter{ !calendar.isDateInWeekend($0) }
            }
        }
        let listingFields = ["Title": title, "Description" : description, "Price" : cost, "Category" : categorySelection, "Availability": calAvail, "Address": ["postalCode": postalCode, "latitude": lat, "longitude": lon], "UID": getCurrentUserUid()] as [String : Any]
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
    func update() {
        var calAvail = [Any]()
        if (!availabilityCalendar.selectedDates.isEmpty) {
            for date in availabilityCalendar.selectedDates {
                calAvail.append(date)
            }
        }
        else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let startOfMonth = calendar.date(from:components)!
            let numberOfDays = calendar.range(of: .day, in: .quarter, for: startOfMonth)!.upperBound
            let allDays = Array(0..<numberOfDays).map{ calendar.date(byAdding:.day, value: $0, to: startOfMonth)!}
            if (availabilitySelection == "Everyday") {
                calAvail = []
            }
            else if (availabilitySelection == "Weekdays") {
                calAvail = allDays.filter{ calendar.isDateInWeekend($0) }
            }
            else if (availabilitySelection == "Weekends") {
                calAvail = allDays.filter{ !calendar.isDateInWeekend($0) }
            }
        }
        let listingFields = ["Title": title, "Description" : description, "Price" : cost, "Category" : categorySelection, "Availability": calAvail, "Address": ["postalCode": postalCode, "latitude": lat, "longitude": lon], "UID": getCurrentUserUid()] as [String : Any]
        if (documentUpdate(collectionPath: "Listings", documentID: editListing.id, data: listingFields)) {
            NSLog("error");
        }
        // upload images and add paths to data fields
        var index = 1
        var imgPath = ""
        var arrayImgs:[String] = []
        for pic in pictures {
            imgPath = "listingimages/" + editListing.id + "/" + String(index) + ".jpg"
            arrayImgs.append(imgPath)
            storageManager.upload(image: pic, path: imgPath)
            index += 1
        }
        if (documentUpdate(collectionPath: "Listings", documentID: editListing.id, data: ["image_path" : arrayImgs])) {
            NSLog("error");
        }
        showPostAlertX = true
    }
    func validatePost () -> Bool {
        if (title.isEmpty || cost.isEmpty || postalCode.isEmpty ||
            pictures.isEmpty || categorySelection.isEmpty || description.isEmpty ||
            (availabilitySelection.isEmpty && availabilityCalendar.selectedDates.isEmpty) || !isPostalCodeValid) {
            errorInField = true
            return false
        }
        return true
    }
    func intializeEditor () {
        isEditing = editListing.title != ""
        if (isEditing) {
            title = editListing.title
            description = editListing.description
            cost = editListing.price
            postalCode = editListing.address["postalCode"] as? String ?? "ERROR"
            availabilityCalendar.selectedDates = editListing.availability
            imagesCount = editListing.imagepath.count
            categorySelection = editListing.category
            imagesCount = (imagesCount <  5) ? imagesCount + 1 : imagesCount
            for path in editListing.imagepath {
                let storageRef = Storage.storage().reference(withPath: path)
                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                    if let error = error {
                        print (error)
                    } else {
                        //Image Returned Successfully:
                        let image = UIImage(data: data!)
                        pictures.append(image!)
                    }
                }
            }
            else {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: Date())
                let startOfMonth = calendar.date(from:components)!
                let numberOfDays = calendar.range(of: .day, in: .quarter, for: startOfMonth)!.upperBound
                let allDays = Array(0..<numberOfDays).map{ calendar.date(byAdding:.day, value: $0, to: startOfMonth)!}
                if (availabilitySelection == "Everyday") {
                    calAvail = []
                }
                else if (availabilitySelection == "Weekdays") {
                    calAvail = allDays.filter{ calendar.isDateInWeekend($0) }
                }
                else if (availabilitySelection == "Weekends") {
                    calAvail = allDays.filter{ !calendar.isDateInWeekend($0) }
                }
            }
            
            getCurrentUser(completion: { user in
                let listingFields = ["Title": title, "Description" : description, "Price" : cost, "Category" : categorySelection, "Availability": calAvail, "Address": postalCode, "UID": getCurrentUserUid(), "name": user.name] as [String : Any]
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
            })
        }
    }
    func validateUpdate () -> Bool {
        if (title == editListing.title && description == editListing.description
            && cost == editListing.price && postalCode == editListing.address["postalCode"] as! String
            && availabilityCalendar.selectedDates == editListing.availability
            && picturesUnchanged && categorySelection == editListing.category) {
            return false
        }
        return true
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
                        Text(isEditing ? "Edit Listing" : "New Post")
                            .font(.title.bold())
                            .frame(width: screenSize.width * 0.9, alignment: .leading)
                            .id(1)
                        
                        imageView
                        
                        fieldEntriesView
                            
                        availabilityView
                        
                        // update button is editing, else Post button
                        Button(action: {
                            if (isEditing) {
                                if (validatePost()) {
                                    update()
                                }
                            }
                            else {
                                withAnimation(.easeInOut(duration: 1)) {
                                    value.scrollTo(1)
                                }
                                // validate entries
                                if (validatePost()) {
                                    post()
                                }
                            }
                        }) {
                            Text((isEditing) ? "Update" : "Post")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.9, height: 20)
                                .padding()
                                .foregroundColor(.white)
                                .background((isEditing && shouldDisableUpdateButton) ? .grey : Color.primaryDark)
                                .cornerRadius(40)
                        }
                        .disabled(isEditing && shouldDisableUpdateButton)
                        
                        // delete listing if editing, else Cancel button
                        Button(action: {
                            if (isEditing) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            else {
                                resetInputs()
                                showCancelAlertX.toggle()
                                withAnimation(.easeInOut(duration: 1)) {
                                    value.scrollTo(1)
                                }
                            }
                        })
                        {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(width: screenSize.width * 0.9, height: 10)
                                .padding()
                                .foregroundColor(.errorColour)
                                .background(.white)
                                .cornerRadius(40)
                                .overlay(RoundedRectangle(cornerRadius: 40) .stroke(Color.errorColour, lineWidth: 2))
                        }
                        .padding(.bottom)
                    }
                }
                // custom availability calendar
                .sheet(isPresented: $showCal) {
                    RKViewController(isPresented: $showCal, rkManager: availabilityCalendar)
                }
                .onChange(of: [title, description, cost, postalCode, categorySelection], perform: { newVal in
                    if (!isEditing) { return }
                    shouldDisableUpdateButton = !validateUpdate()
                })
                .onChange(of: [picturesUnchanged], perform: { newVal in
                    if (!isEditing) { return }
                    shouldDisableUpdateButton = !validateUpdate()
                })
                .onChange(of: showCal, perform: { newVal in
                    if (!isEditing) { return }
                    shouldDisableUpdateButton = !validateUpdate()
                })

                PopUp(show: $errorInField) {
                    VStack {
                        Text("Entries missing or incorrectly filled")
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
                        Text((isEditing) ? "Listing Updated!" : "Listing Posted!")
                            .foregroundColor(.primaryDark)
                            .bold()
                            .padding(.bottom)
                        Button(action: {
                            if (isEditing) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
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
        .onAppear() {
            intializeEditor()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
