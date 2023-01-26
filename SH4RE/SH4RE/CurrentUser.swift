//
//  CurrentUser.swift
//  SH4RE
//
//  Created by Bryan Brown on 2023-01-18.
//
import SwiftUI
import FirebaseAuth

//class used to manage view transitions 
class CurrentUser : ObservableObject{
    @Published var hasLoggedIn: Bool
    init() {
        self.hasLoggedIn = Bool(Auth.auth().currentUser != nil)
    }
    
    func isGuest() -> Bool{
        if(self.hasLoggedIn){
            return Auth.auth().currentUser!.isAnonymous
        }
        return false
    }
}
