//
//  FilterSheetView.swift
//  SH4RE
//
//  Created by Americo on 2023-01-19.
//

import SwiftUI
import Combine

struct FilterSheetView: View {
//    let screenSize: CGRect = UIScreen.main.bounds
    
    
    var dropDownList = ["Tools", "Sporting Equipment", "Cameras", "Cooking"]
    var dropDownPlaceholder = "Category"
    @State private var birthMonth: DropdownMenuOption? = nil
    @State private var revealDetails = false
    @State private var dropDownSelection: String = ""

    @State private var location: String = ""
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var maxDistance: String = ""
    
    @State private var rating4 = 2.3

    var body: some View {
//        ZStack (alignment: .topLeading){
            VStack (alignment: .leading) {
                Group {
                    Text("Filters")
                        .font(.title)
                        .bold()
                    
                    //Location
                    VStack (alignment: .leading) {
                        Text("Location")
                            .font(.title2)
                        TextField("Location", text: $location)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    //Categories
                    VStack (alignment: .leading){
                        Text("Category")
                            .font(.title2)
                        GroupBox {
                            DisclosureGroup("Categories") {
                                Text("Item 1")
                                Text("Item 2")
                                Text("Item 3")
                            }.disclosureGroupStyle(CustomDisclosureGroupStyle(button: Text("ok")))
                        }
                        
                        VStack {
                            DropdownMenu(
                                selectedOption: self.$birthMonth,
                                placeholder: "Category",
                                options: DropdownMenuOption.testAllMonths
                            )
                            
                            Text(birthMonth?.option ?? "")
                        }
                    }
                    
                    //Price
                    VStack {
                        Text("Daily Price")
                            .font(.title2)
                        HStack {
                            TextField("Min", text: $minPrice)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .onReceive(Just(minPrice)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.minPrice = filtered
                                    }
                                }
                            TextField("Max", text: $maxPrice)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .onReceive(Just(maxPrice)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.minPrice = filtered
                                    }
                                }
                        }
                    }
                    
                    //Distance
                    VStack {
                        Text("Max Distance")
                            .font(.title2)
                        TextField("Max Distance", text: $maxDistance)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onReceive(Just(maxDistance)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.maxDistance = filtered
                                }
                            }
                    }
                    
                    //Rating
                    VStack {
                        Text("Min Rating")
                            .font(.title2)
                        StarsView(numberOfStars: 3.5)
                    }
//                    HStack(spacing:10) {
//                        StarRatingView(value: $rating4, stars: 5)
//                            .frame(width: 200, height: 40, alignment: .center)
//                        Circle()
//                            .fill(.gray)
//                            .frame(width: 40, height: 40, alignment: .center)
//                            .overlay(
//                                Text("\(rating4, specifier: "%.1F")")
//                                    .foregroundColor(.white)
//                                    .fontWeight(.bold)
//                            )
//                    }
//                    ratingPickerView(rating: $rating4)
                    RatingsView(rating: $rating4)
                }
                .padding(.bottom, 3)
            }
            .padding()
//        }
    }
}

struct CustomDisclosureGroupStyle<Label: View>: DisclosureGroupStyle {
    let button: Label
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            button
                .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .padding()//.leading, 30)
                .disclosureGroupStyle(self)
        }
    }
}

struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView()
    }
}
