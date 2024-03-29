//
//  SearchModel.swift
//  SH4RE
//
//  Created by Americo on 2023-03-13.
//

import SwiftUI

struct CompletedSearchQuery {
    var searchQuery: String
    var category: String
    var location: String
    var minPrice: Int
    var maxPrice: Int
    var maxDistance: Int
    var minRating: Double
    var startDate: Date
    var endDate: Date
    var latitude: Double
    var longitude: Double
}

class SearchModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchReady: Bool = true
    @Published var recentSearchQueries: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearchQueries") ?? [""]
    @Published var category: String = ""
    @Published var location: String = ""
    @Published var minPrice: String = ""
    @Published var maxPrice: String = ""
    @Published var maxDistance: String = ""
    @Published var minRating:Double = 0.0
    @Published var startDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    @Published var endDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    @Published var latitude:Double = 0.0
    @Published var longitude:Double = 0.0
    
    func resetFilters(){
        category = ""
        location = ""
        minPrice = ""
        maxPrice = ""
        maxDistance = ""
        minRating = 0.0
        startDate = Date(timeIntervalSinceReferenceDate: 0)
        endDate = Date(timeIntervalSinceReferenceDate: 0)
        latitude = 0.0
        longitude = 0.0
    }
    
    func filtersAreApplied() -> Bool {
        if (category == "" &&
            location == "" &&
            minPrice == "" &&
            maxPrice == "" &&
            maxDistance == "" &&
            minRating == 0.0 &&
            startDate == Date(timeIntervalSinceReferenceDate: 0) &&
            endDate == Date(timeIntervalSinceReferenceDate: 0)
        ){
            return false
        }
        return true
    }
    
    func getCompletedSearch() -> CompletedSearchQuery {
        return CompletedSearchQuery(searchQuery: searchQuery, category: category, location: location, minPrice: Int(minPrice) ?? 0, maxPrice: Int(maxPrice) ?? 1000000, maxDistance: Int(maxDistance) ?? 1000000, minRating: minRating, startDate: startDate, endDate: endDate, latitude: latitude, longitude: longitude)
    }
}
