//
//  FilterSheetView.swift
//  SH4RE
//
//  Created by Americo on 2023-01-19.
//

import SwiftUI
import Combine

struct LocationEntryField: View {
    @Binding var location: String
    var body: some View {
        HStack {
            TextField("Location", text: $location)
                .textFieldStyle(
                    locationInputStyle(
                        button: Button(action:{
                            // Currently no action, have to set up location
                            // This could be a staring point https://www.youtube.com/watch?v=cOD1l2lv2Jw&ab_channel=azamsharp
                        }, label:{
                            Image(systemName: "scope")
                        })
                    )
                )
        }
    }
}

struct FilterSheetView: View {
    
    var dropDownList = ["Film & Photography", "Audio Visual Equipment", "Projectors & Screens", "Drones", "DJ Equipment", "Transport", "Storage", "Electronics", "Party & Events", "Sports", "Musical Instruments", "Home, Office & Garden", "Holiday & Travel", "Clothing"]
    @State private var dropDownSelection: String = ""

    @State private var location: String = ""
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var maxDistance: String = ""
    
    @State private var minRating = 0.0

    fileprivate func NumericTextField(label: String, textEntry: Binding<String>) -> some View {
        return TextField(label, text: textEntry)
            .keyboardType(.numberPad)
            .textFieldStyle(textInputStyle())
            .onReceive(Just(minPrice)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    self.minPrice = filtered
                }
            }
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                Group {
                    Text("Filters")
                        .font(.title)
                        .bold()
                    
                    //Location
                    VStack (alignment: .leading) {
                        Text("Location")
                            .font(.title2)
                        LocationEntryField(location: $location)
                    }
                    
                    //Categories
                    VStack (alignment: .leading){
                        Text("Category")
                            .font(.title2)
                        DropdownMenu(label: "Categories", options: dropDownList, selection: $dropDownSelection, useClear: true, clearValue: "")
                    }
                    
                    //Price
                    VStack (alignment: .leading) {
                        Text("Daily Price")
                            .font(.title2)
                        HStack {
                            NumericTextField(label: "Min", textEntry: $minPrice)
                            NumericTextField(label: "Max", textEntry: $maxPrice)
                        }
                    }

                    //Distance
                    VStack (alignment: .leading) {
                        Text("Max Distance")
                            .font(.title2)
                        NumericTextField(label: "Max Distance", textEntry: $maxDistance)
                    }

                    //Rating
                    VStack  {
                        Text("Min Rating")
                            .font(.title2)
                        RatingsView(rating: $minRating)
                            .scaleEffect(2, anchor: .topLeading)
                    }
                }
                .padding(.bottom, 3)
            }
            .padding()
        }
        .background(Color("BackgroundGrey"))
    }
}



struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView()
    }
}



