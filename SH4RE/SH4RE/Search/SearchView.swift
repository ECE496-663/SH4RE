//
//  SearchView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//
import SwiftUI
import FirebaseStorage

//Database stuff to know
//listingView.listings if a list of Listing structs defined in ListingViewModel
//from listing struct you can get id, title, description and cost
//listingView.image_dict is a dict of <String:UIImage> that maps listing ids to images
//needed this separate for now because of sychronous queries

struct SearchView: View {
    @Binding var tabSelection: Int
    @State private var searchQuery: String = ""

    @ObservedObject private var listingsView = ListingViewModel()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    @State var showingFilterSheet = true

    var body: some View {
//        NavigationView {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20){
                    ForEach(listingsView.listings) { listing in
                        // If theres no image for a listing, just use the placeholder
                        let productImage = listingsView.image_dict[listing.id] ?? UIImage(named: "placeholder")!
                        NavigationLink(destination: {
                            ViewListingView(tabSelection: $tabSelection, listing: listing)
                        }, label: {
                            ProductCard(listing: listing, image: productImage)
                        })
                    }
                }.padding()
            }
            .background(Color.backgroundGrey)
            .toolbar {
                HStack (spacing: 15) {
                    TextField("Search", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                    Button("Filter") {
                        showingFilterSheet.toggle();
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingFilterSheet) {
                        FilterSheetView()
                            .presentationDetents([.medium])
                    }
                }
                .padding()
                .frame(width: screenSize.width)
            }
        }
        .onAppear(){
            self.listingsView.fetchListings(completion: { success in
                if success{
                    self.listingsView.fetchProductMainImage( completion: { success in
                        if !success {
                            print("Failed to load images")
                        }
                    })
                } else {
                    print("Failed to query database")
                }
                
            })
        }
    }
}

struct FilterSheetView: View {
    let screenSize: CGRect = UIScreen.main.bounds
    var dropDownList = ["Tools", "Sporting Equipment", "Cameras", "Cooking"]
    var dropDownPlaceholder = "Category"
    
    @State private var location: String = ""
    @State private var dropDownSelection: String = ""
    
    var body: some View {
        ZStack (alignment: .topLeading){
            VStack (alignment: .leading) {
                Text("Filters")
                    .font(.title)
                    .bold()
                
                Text("Location")
                    .font(.title2)
                TextField("Location", text: $location)
                    .textFieldStyle(.roundedBorder)
                
                GroupBox {
                    DisclosureGroup("Menu 1") {
                        Text("Item 1")
                        Text("Item 2")
                        Text("Item 3")
                    }
                }
                
                let options = [
                        DropdownOption(key: "week", val: "This week"), DropdownOption(key: "month", val: "This month"), DropdownOption(key: "year", val: "This year")
                    ]

                  let onSelect = { key in
                        print(key)
                    }
                
                Group {
                            VStack(alignment: .leading) {
                                DropdownButton(displayText: .constant("This month"), options: options, onSelect: onSelect)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color.black)
                    }
//                Picker("Select a paint color", selection: $dropDownSelection) {
//                    ForEach(dropDownList, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle)
//                Menu {
//                    ForEach(dropDownList, id: \.self){ client in
//                        Button(client) {
//                            dropDownSelection = " "+client
//                        }
//                    }
//                } label: {
//                    VStack{
//                        HStack{
//                            Text(dropDownPlaceholder.isEmpty ? dropDownPlaceholder : dropDownSelection)
//                                .foregroundColor(dropDownSelection.isEmpty ? Color("TextFieldInputDefault") : .black)
//                            Spacer()
//                            Image(systemName: "arrowtriangle.left.fill")
//                                .foregroundColor(Color.init(UIColor(named: "TextFieldInputDefault")!))
//                        }
//                        .frame(width: screenSize.width * 0.9, height: 30)
//                        .background(.white)
//                        .cornerRadius(5)
//                    }
//                }
            }
            .padding()
        }
    }
}


let dropdownCornerRadius: CGFloat = 20
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(tabSelection: .constant(1))
    }
}

struct DropdownOption: Hashable {
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }

    var key: String
    var val: String
}

struct DropdownOptionElement: View {
    var val: String
    var key: String
    var onSelect: ((_ key: String) -> Void)?

    var body: some View {
        Button(action: {
            if let onSelect = self.onSelect {
                onSelect(self.key)
            }
        }) {
            Text(self.val)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
}

struct DropdownButton: View {
    @State var shouldShowDropdown = false
    @Binding var displayText: String
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?

    let buttonHeight: CGFloat = 30
    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text(displayText)
                Spacer()
                    .frame(width: 20)
                Image(systemName: self.shouldShowDropdown ? "chevron.up" : "chevron.down")
            }
        }
        .padding(.horizontal)
        .cornerRadius(dropdownCornerRadius)
        .frame(height: self.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: dropdownCornerRadius)
                .stroke(Color.black, lineWidth: 1)
        )
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 10)
                    Dropdown(options: self.options, onSelect: self.onSelect)
                }
            }, alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: dropdownCornerRadius).fill(Color.white)
        )
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(self.options, id: \.self) { option in
                DropdownOptionElement(val: option.val, key: option.key, onSelect: self.onSelect)
            }
        }

        .background(Color.white)
        .cornerRadius(dropdownCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: dropdownCornerRadius)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}
