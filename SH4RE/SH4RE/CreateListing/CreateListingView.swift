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
    @AppStorage("UID") var username: String = (UserDefaults.standard.string(forKey: "UID") ?? "")
    var storageManager = StorageManager()
    @Binding var tabSelection: Int

    // image entry
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
    
    var body: some View {
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            if (username.isEmpty) {
                GuestView(tabSelection: $tabSelection)
            }
            else {
                VStack {
                    GeometryReader { geometry in
                        ImageCarouselView(numberOfImages: imagesCount) {
                            ForEach(pictures, id:\.self) { picture in
                                Image(uiImage: picture)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: 250)
                                    .aspectRatio(contentMode: .fill)
                            }
                            if (imagesCount < 6) {
                                Image("CreateListingBkgPic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: 250)
                                    .aspectRatio(contentMode: .fill)
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
                        }
                    }
                    .environment(\.deleteImage, deleteImage)
                    // this just opens the sheet to select a photo from library
                    .sheet(isPresented: $showSheet) {
                        // Pick an image from the photo library:
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
                        
                        //  If you wish to take a photo from camera instead:
                        // ImagePicker(sourceType: .camera, selectedImage: self.$image)
                    }
                    .frame(maxHeight: 300)
                    
                    //divider
                    Color.gray
                        .frame(width: screenSize.width * 0.95, height: 1 / UIScreen.main.scale)
                        .padding(.top)
                    
                    ScrollView([.vertical]) {
                        // title entry
                        TextField("Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: screenSize.width * 0.9, height: 20)
                            .padding()
                        
                        // category entry
                        Menu {
                            ForEach(categoryList, id: \.self){ selection in
                                Button(selection) {
                                    categorySelection = " " + selection
                                }
                            }
                        } label: {
                            VStack{
                                HStack{
                                    Text(categorySelection.isEmpty ? categoryPlaceholder : categorySelection)
                                        .foregroundColor(categorySelection.isEmpty ? customColours["textfield"]! : .black)
                                    Spacer()
                                    Image(systemName: "arrowtriangle.left.fill")
                                        .foregroundColor(customColours["textfield"]!)
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
                                    cost = filtered
                                }
                            }
                            .frame(width: screenSize.width * 0.9, height: 20)
                            .padding()
                        
                        // postal code entry
                        TextField("Postal Code e.g. A1A 1A1", text: $postalCode)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: screenSize.width * 0.9, height: 20)
                            .padding()
                        
                        Text("Availability")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: screenSize.width * 0.9, alignment: .leading)
                            .padding(.bottom)
                        
                        // availability
                        Menu {
                            ForEach(availabilityList, id: \.self){ selection in
                                Button(selection) {
                                    showCal = false
                                    dates = []
                                    availabilitySelection = " " + selection
                                }
                            }
                        } label: {
                            VStack{
                                HStack{
                                    Text(availabilitySelection.isEmpty ? availabilityPlaceholder : availabilitySelection)
                                        .foregroundColor(availabilitySelection.isEmpty ? Color("TextFieldInputDefault") : Color("Black"))
                                    Spacer()
                                    Image(systemName: "arrowtriangle.left.fill")
                                        .foregroundColor(Color("TextFieldInputDefault"))
                                }
                                .frame(width: screenSize.width * 0.9, height: 30)
                                .background(.white)
                                .cornerRadius(5)
                            }
                        }
                        HStack {
                            Text("or make a")
                            Button(action: {
                                showCal = true
                                availabilitySelection = ""
                            }) {
                                Text("Custom Availability")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(customColours["primaryBase"]!)
                        }
                        .frame(maxWidth: screenSize.width * 0.85, alignment: .leading)
                        
                        // custom availability calendar
                        if (showCal) {
                            MultiDatePicker(
                                "Start Date",
                                selection: $dates,
                                in: bounds
                            )
                            .datePickerStyle(.graphical)
                            .frame(maxWidth: screenSize.width * 0.9)
                            .tint(customColours["primaryBase"]!)
                        }
                        Group {
                            // POST
                            Button(action: {
                                // validate entries
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
                                    let listingFields = ["Title": title, "Description" : description, "Price" : cost, "Category" : categorySelection, "Availability": calAvail, "Address": postalCode]
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
                                    
                                    //reset inputs
                                    pictures = []
                                    imagesCount = 1
                                    title = ""
                                    description = ""
                                    cost = ""
                                    postalCode = ""
                                    categorySelection = ""
                                    availabilitySelection = ""
                                    showCal = false
                                    showPostAlertX = true
                                }
                            }) {
                                Text("Post")
                                    .fontWeight(.semibold)
                                    .frame(width: screenSize.width * 0.9, height: 20)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(customColours["primaryDark"]!)
                                    .cornerRadius(40)
                            }
                            .alertX(isPresented: $errorInField, content: {
                                AlertX(
                                    title: Text("ERROR: Entries missing"),
                                    theme: AlertX.Theme.custom(
                                        windowColor: customColours["error"]!,
                                        alertTextColor: .white,
                                        enableShadow: true,
                                        enableRoundedCorners: true,
                                        enableTransparency: false,
                                        cancelButtonColor: .white,
                                        cancelButtonTextColor: .white,
                                        defaultButtonColor: customColours["primaryDark"]!,
                                        defaultButtonTextColor: .white
                                    )
                                )
                            })
                            .alertX(isPresented: $showPostAlertX, content: {
                                AlertX(
                                    title: Text("Listing Posted!"),
                                    theme: AlertX.Theme.custom(
                                        windowColor: .white,
                                        alertTextColor: customColours["primaryDark"]!,
                                        enableShadow: true,
                                        enableRoundedCorners: true,
                                        enableTransparency: false,
                                        cancelButtonColor: .white,
                                        cancelButtonTextColor: .white,
                                        defaultButtonColor: customColours["primaryDark"]!,
                                        defaultButtonTextColor: .white
                                    )
                                )
                            })
                            
                            // Cancel
                            Button(action: {
                                pictures = []
                                imagesCount = 1
                                title = ""
                                description = ""
                                cost = ""
                                postalCode = ""
                                categorySelection = ""
                                availabilitySelection = ""
                                showCal = false
                                showCancelAlertX.toggle()
                            })
                            {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .frame(width: screenSize.width * 0.9, height: 10)
                                    .padding()
                                    .foregroundColor(customColours["primaryDark"]!)
                                    .background(.white)
                                    .cornerRadius(40)
                                    .overlay(RoundedRectangle(cornerRadius: 40) .stroke(customColours["primaryDark"]!, lineWidth: 2))
                            }
                            .padding(.bottom)
                            .alertX(isPresented: $showCancelAlertX, content: {
                                AlertX(
                                    title: Text("Listing Cleared"),
                                    theme: AlertX.Theme.custom(
                                        windowColor: .white,
                                        alertTextColor: customColours["primaryDark"]!,
                                        enableShadow: true,
                                        enableRoundedCorners: true,
                                        enableTransparency: false,
                                        cancelButtonColor: .white,
                                        cancelButtonTextColor: .white,
                                        defaultButtonColor: customColours["primaryDark"]!,
                                        defaultButtonTextColor: .white
                                    )
                                )
                            })
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TextEditorWithPlaceholder: View {
    @Binding var text: String

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
                    .opacity(text.isEmpty ? 0.8 : 1)
                    .cornerRadius(5)
                    .padding()
            }
        }
    }
}
