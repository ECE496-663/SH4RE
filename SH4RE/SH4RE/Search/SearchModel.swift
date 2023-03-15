//
//  SearchModel.swift
//  SH4RE
//
//  Created by Americo on 2023-03-13.
//

import SwiftUI

class SearchModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchReady: Bool = true
    @Published var recentSearchQueries: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearchQueries") ?? [""]
}
