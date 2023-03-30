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
                            // Additionally, check out the file "CurrentLocationButton"
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
    
    @ObservedObject var searchModel: SearchModel
    @State private var category: String = ""
    @State private var location: String = ""
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var maxDistance: String = ""
    @State private var minRating = 0.0
    @Binding var showingFilterSheet: Bool
    var doSearch: () -> Void
    
    init(searchModel: SearchModel, showingFilterSheet: Binding<Bool>, doSearch: @escaping () -> Void ) {
        category = searchModel.category
        location = searchModel.location
        minPrice = searchModel.minPrice
        maxPrice = searchModel.maxPrice
        maxDistance = searchModel.maxDistance
        minRating = searchModel.minRating
        self._showingFilterSheet = showingFilterSheet
        self.searchModel = searchModel
        self.doSearch = doSearch
    }
    
    fileprivate func setFilters(){
        searchModel.category = category
        searchModel.location = location
        searchModel.minPrice = minPrice
        searchModel.maxPrice = maxPrice
        searchModel.maxDistance = maxDistance
        searchModel.minRating = minRating
    }
    
    fileprivate func NumericTextField(label: String, textEntry: Binding<String>, error: Bool = false) -> some View {
        return TextField(label, text: textEntry)
            .keyboardType(.numberPad)
            .textFieldStyle(textInputStyle(error: error))
            .onReceive(Just(textEntry.wrappedValue)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    textEntry.wrappedValue = filtered
                }
            }
    }
    
    /// If the max is defined, and it is less than the min, it will return an error, expects strings to be numbers
    fileprivate func minMaxError(min:String, max:String) -> Bool {
        if(maxPrice != "") {
            return Int(maxPrice) ?? 0 < Int(minPrice) ?? 0
        }
        return false
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                Group {
                    HStack {
                        Text("Filter")
                            .font(.title)
                            .bold()
                        Spacer()
                        Button("Apply", action: {
                            if (!minMaxError(min: minPrice, max: maxPrice)){
                                setFilters()
                                doSearch()
                                showingFilterSheet.toggle()
                            }
                        }).buttonStyle(primaryButtonStyle(width: 80))
                        
                    }
                    
                    //Location
                    VStack (alignment: .leading) {
                        Text("Location")
                            .font(.title2)
                        LocationEntryField(location: $location)
                    }
                    
                    //Distance
                    VStack (alignment: .leading) {
                        Text("Max Distance")
                            .font(.title2)
                        NumericTextField(label: "Max Distance", textEntry: $maxDistance)
                    }
                    
                    //Categories
                    VStack (alignment: .leading){
                        Text("Category")
                            .font(.title2)
                        DropdownMenu(label: "Categories", options: dropDownList, selection: $category, useClear: true, clearValue: "")
                    }
                    
                    //Price
                    VStack (alignment: .leading) {
                        Text("Daily Price")
                            .font(.title2)
                        HStack {
                            NumericTextField(label: "Min", textEntry: $minPrice, error: minMaxError(min: minPrice, max: maxPrice))
                            NumericTextField(label: "Max", textEntry: $maxPrice, error: minMaxError(min: minPrice, max: maxPrice))
                        }
                    }

                    //Rating
                    VStack (alignment: .leading) {
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
        FilterSheetView(searchModel: SearchModel(), showingFilterSheet: .constant(true), doSearch: {})
    }
}



