//
//  FilterSheetView.swift
//  SH4RE
//
//  Created by Americo on 2023-01-19.
//

import SwiftUI
import Combine
import CoreLocationUI
import CoreLocation

struct LocationEntryField: View {
    @Binding var location: String
    @Binding var locationManager: LocationManager

    var body: some View {
        HStack {
            TextField("Postal Code e.g. A1A 1A1", text: $location)
                .textFieldStyle(
                    locationInputStyle(
                        button: LocationButton {
                            locationManager.requestLocation()
                            location = "Current Location"
                        }
                    )
                )
        }
    }
}

struct FilterSheetView: View {
    
    var dropDownList = ["Film & Photography", "Audio Visual Equipment", "Projectors & Screens", "Drones", "DJ Equipment", "Transport", "Storage", "Electronics", "Party & Events", "Sports", "Musical Instruments", "Home, Office & Garden", "Holiday & Travel", "Clothing"]
    
    @ObservedObject var searchModel: SearchModel
    @State private var category: String
    @State private var location: String
    @State private var minPrice: String
    @State private var maxPrice: String
    @State private var maxDistance: String
    @State private var minRating: Double
    @State private var startDate: Date
    @State private var endDate: Date
    @Binding var showingFilterSheet: Bool
    @Binding var locationManager: LocationManager
    var doSearch: () -> Void
    
    init(searchModel: SearchModel, showingFilterSheet: Binding<Bool>, locationManager: Binding<LocationManager>, doSearch: @escaping () -> Void ) {
        self.doSearch = doSearch
        self.searchModel = searchModel
        _showingFilterSheet = showingFilterSheet
        _locationManager = locationManager
        _category =  State(initialValue: searchModel.category)
        _location = State(initialValue: searchModel.location)
        _minPrice = State(initialValue: searchModel.minPrice)
        _maxPrice = State(initialValue: searchModel.maxPrice)
        _maxDistance = State(initialValue: searchModel.maxDistance)
        _minRating = State(initialValue: searchModel.minRating)
        _startDate = State(initialValue: searchModel.startDate)
        _endDate = State(initialValue: searchModel.endDate)
    }
    
    func isPostalCodeValid (postalCode: String) -> Bool {
        if (postalCode == "Current Location") {
            return true
        }
        let range = NSRange(location: 0, length: postalCode.utf16.count)
        let regex1 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z][0-9][A-Za-z][0-9]")
        let res1 = regex1!.firstMatch(in: postalCode, options: [], range: range)
        let regex2 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z]-[0-9][A-Za-z][0-9]")
        let res2 = regex2!.firstMatch(in: postalCode, options: [], range: range)
        let regex3 = try? NSRegularExpression(pattern: "[A-Za-z][0-9][A-Za-z] [0-9][A-Za-z][0-9]")
        let res3 = regex3!.firstMatch(in: postalCode, options: [], range: range)
        if (res1 != nil || res2 != nil || res3 != nil) {
            return true
        }
        return false
    }
    
    func updateLocation (postalCode: String) {
        if (postalCode == "") {
            return
        }
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(postalCode) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
            // Use your location
            locationManager.updateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }

    }
    
    fileprivate func setFilters(){
        searchModel.category = category
        searchModel.location = (isPostalCodeValid(postalCode: location)) ? location : ""
        searchModel.minPrice = minPrice
        searchModel.maxPrice = maxPrice
        searchModel.maxDistance = maxDistance
        searchModel.minRating = minRating
        searchModel.startDate = startDate
        searchModel.endDate = endDate
        locationManager.updateDistance(distance: ((maxDistance == "") ? 3.0 : Double(maxDistance))!)
        updateLocation(postalCode: location)
        if (location == "Current Location") {
            searchModel.latitude = locationManager.location.coordinate.latitude
            searchModel.longitude = locationManager.location.coordinate.longitude
        }
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
    
    fileprivate func filterSheetHeader() -> some View {
        return HStack {
            Text("Filter")
                .font(.title)
                .bold()
            Spacer()
            Button("Clear", action: {
                searchModel.resetFilters()
                doSearch()
                showingFilterSheet.toggle()
                locationManager.updateDistance(distance: 3.0)
            })
            .foregroundColor(.primaryDark)
            .padding(.horizontal)
            Button("Apply", action: {
                if (!minMaxError(min: minPrice, max: maxPrice)){
                    setFilters()
                    doSearch()
                    showingFilterSheet.toggle()
                }
            }).buttonStyle(primaryButtonStyle(width: 80))
            
        }
    }
    
    private var border: some View {
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(
            .gray,
          lineWidth: 1
        )
    }
    
    fileprivate func availabilitySelection() -> some View {
        return HStack {
            Spacer()
            SwiftUI.DatePicker(
                    "Please enter a start date",
                    selection: $startDate,
                    //Range is from today until 3 months from today
                    in: Date.now...Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .onTapGesture {
                    if (startDate == Date(timeIntervalSinceReferenceDate: 0)) {
                        //If this isn't set, it will display the date as today is selected, but in the backend, it will still be the initalValue
                        startDate = Date.now
                    }
                }
                .onChange(of:startDate, perform: { value in
                    //Make sure end date gets updated to
                    if(startDate > endDate){
                        endDate = startDate
                    }
                })
                .overlay{
                    if (startDate == Date(timeIntervalSinceReferenceDate: 0)) {
                        Group {
                            Rectangle()
                                .cornerRadius(8)
                                .foregroundColor(Color(red: 0.914, green: 0.914, blue: 0.918))
                            Text("MM/DD/YY")
                        }.allowsHitTesting(false)
                    }
                }
            Text("-")
                .padding(.horizontal)
            SwiftUI.DatePicker(
                    "Please enter an end date",
                    selection: $endDate,
                    //Use startDate or the current date, whichever is the most recent for the range.
                    in: (startDate < Date.now ? Date.now : startDate)...Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .onChange(of:endDate, perform: { value in
                    //Make sure end date gets updated to
                    if(startDate == Date(timeIntervalSinceReferenceDate: 0)){
                        startDate = Date.now
                    }
                })
                .overlay{
                    if (endDate == Date(timeIntervalSinceReferenceDate: 0)) {
                        Group {
                            Rectangle()
                                .cornerRadius(8)
                                .foregroundColor(Color(red: 0.914, green: 0.914, blue: 0.918))
                            Text("MM/DD/YY")
                        }.allowsHitTesting(false)
                    }
                }
            Spacer()
        }
        .padding()
        .accentColor(.primaryBase)
        .background(border)
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                Group {
                    filterSheetHeader()
                    
                    //Location
                    VStack (alignment: .leading) {
                        Text("Location")
                            .font(.title2)
                        LocationEntryField(location: $location, locationManager: $locationManager)
                    }

                    //Distance
                    VStack (alignment: .leading) {
                        Text("Max Distance")
                            .font(.title2)
                        NumericTextField(label: "Distance in Kilometers", textEntry: $maxDistance)
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
                            .padding(.bottom)
                    }
                    
                    //Availability
                    VStack (alignment: .leading) {
                        Text("Availability")
                            .font(.title2)
                        availabilitySelection()
                    }
                }
                .padding(.bottom, 3)
            }
            .padding()
        }
        .background(Color("BackgroundGrey"))
    }
}
