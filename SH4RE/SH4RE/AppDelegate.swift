//
//  AppDelegate.swift
//  SH4RE
//
//  Created by February on 2023-03-10.
//

import Foundation
import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDdEEPgx3IzPQl-aBZV3A-JagiuUz0QCsk")
        return true
    }
}
