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

struct LoginControlView: View {
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = UserDefaults.standard.bool(forKey: "hasSeenTutorial")
    
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
        showLogin = true
    }
    
    func showCreateAccountScreen() {
        showLogin = false
        showCreateAccount = true
    }

    var body: some View {
        ZStack {
            LandingView()
                .position(x: screenSize.width * 0.5, y: (closeSplashScreen) ? screenSize.height * -2 : screenSize.height * 0.452)

            if (!closeTutorialScreen) {
                TutorialView()
                    .environment(\.showLoginScreen, showLoginScreen)
                    .position(x: screenSize.width * 0.5, y: (closeSplashScreen) ? screenSize.height * 0.452 : screenSize.height * 2)
            }
            else {
                LoginView()
                    .environment(\.showCreateAccountScreen, showCreateAccountScreen)
                    .position(x: screenSize.width * 0.5, y: (showLogin) ? screenSize.height * 0.452 : screenSize.height * -2)
                if (showCreateAccount) {
                    CreateAccountView()
                        .environment(\.showLoginScreen, showLoginScreen)
                }
            }

        }
        .background(Color.backgroundGrey)
        .ignoresSafeArea(.keyboard)
        .onReceive(timer, perform: { _ in
            withAnimation(.default) {
                closeSplashScreen = true
                closeTutorialScreen = hasSeenTutorial
                showLogin = hasSeenTutorial
                timer.upstream.connect().cancel()
            }
        })
    }
}

struct LoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        LoginControlView()
    }
}
