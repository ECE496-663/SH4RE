//
//  LoginFlow.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct ParentLoginKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}
extension EnvironmentValues {
    var showLoginScreen: (() -> Void)? {
        get { self[ParentLoginKey.self] }
        set { self[ParentLoginKey.self] = newValue }
    }
    
    var showCreateAccount: (() -> Void)? {
        get { self[ParentLoginKey.self] }
        set { self[ParentLoginKey.self] = newValue }
    }
}

struct LoginFlow: View {
    @State private var close_splash_screen = false
    @State private var close_tutorial_screen = false
    @State private var show_login = false
    @State private var show_create_account = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @EnvironmentObject var currentUser : CurrentUser

    func showLoginScreen() {
        if (self.show_create_account) {
            self.show_create_account = false
            self.show_login = true
        }
        self.close_tutorial_screen = true
    }
    
    func showCreateAccount() {
        self.show_login = false
        self.show_create_account = true
    }

    var body: some View {
        ZStack {
            LandingScreen()
                .position(x: screenSize.width * 0.5, y: (self.close_splash_screen) ? screenSize.height * -2 : screenSize.height * 0.452)

            if (!close_tutorial_screen) {
                Tutorial()
                    .environment(\.showLoginScreen, showLoginScreen)
                    .position(x: screenSize.width * 0.5, y: (self.close_splash_screen) ? screenSize.height * 0.452 : screenSize.height * 2)
            }
            else {
                LoginPage()
                    .environment(\.showCreateAccount, showCreateAccount).environmentObject(currentUser)
                    .position(x: screenSize.width * 0.5, y: (self.show_login) ? screenSize.height * 0.452 : screenSize.height * -2)
                if (show_create_account) {
                    CreateAccount()
                        .environment(\.showLoginScreen, showLoginScreen).environmentObject(currentUser)
                }
            }

        }
        .onReceive(timer, perform: { _ in
            withAnimation(.default) {
                self.close_splash_screen = true
                self.show_login = self.close_tutorial_screen
                self.timer.upstream.connect().cancel()
            }
        })
        .onChange(of: self.close_tutorial_screen, perform: { _ in
            withAnimation(.default) {
                self.close_splash_screen = false
                self.close_tutorial_screen = true
                self.timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
            }
        })
    }
}

struct LoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlow()
    }
}
