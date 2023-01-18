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
    
    var showCreateAccountScreen: (() -> Void)? {
        get { self[ParentLoginKey.self] }
        set { self[ParentLoginKey.self] = newValue }
    }
}

struct LoginFlow: View {
    @State private var closeSplashScreen = false
    @State private var closeTutorialScreen = false
    @State private var showLogin = false
    @State private var showCreateAccount = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func showLoginScreen() {
        if (showCreateAccount) {
            showCreateAccount = false
            showLogin = true
        }
        closeTutorialScreen = true
    }
    
    func showCreateAccountScreen() {
        showLogin = false
        showCreateAccount = true
    }

    var body: some View {
        ZStack {
            LandingScreen()
                .position(x: screenSize.width * 0.5, y: (closeSplashScreen) ? screenSize.height * -2 : screenSize.height * 0.452)

            if (!closeTutorialScreen) {
                Tutorial()
                    .environment(\.showLoginScreen, showLoginScreen)
                    .position(x: screenSize.width * 0.5, y: (closeSplashScreen) ? screenSize.height * 0.452 : screenSize.height * 2)
            }
            else {
                LoginPage()
                    .environment(\.showCreateAccountScreen, showCreateAccountScreen)
                    .position(x: screenSize.width * 0.5, y: (showLogin) ? screenSize.height * 0.452 : screenSize.height * -2)
                if (showCreateAccount) {
                    CreateAccount()
                        .environment(\.showLoginScreen, showLoginScreen)
                }
            }

        }
        .onReceive(timer, perform: { _ in
            withAnimation(.default) {
                closeSplashScreen = true
                showLogin = closeTutorialScreen
                timer.upstream.connect().cancel()
            }
        })
        .onChange(of: closeTutorialScreen, perform: { _ in
            withAnimation(.default) {
                closeSplashScreen = false
                closeTutorialScreen = true
                timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
            }
        })
    }
}

struct LoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlow()
    }
}
