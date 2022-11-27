//
//  ViewListing.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase

class ViewListing: ObservableObject {

    var test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", title:"Test Listing", description: "Test Description", imagepath : "path")
    var body: some Scene {
        WindowGroup {
            ViewListingView(listing : test_listing)
        }
    }
}
