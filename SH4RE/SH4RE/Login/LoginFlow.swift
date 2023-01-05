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
}

struct LoginFlow: View {
    @State private var close_splash_screen = false
    @State private var close_tutorial_screen = false
    @State private var show_login = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func showLoginScreen() {
        self.close_tutorial_screen = true
    }

    var body: some View {
        let screenSize: CGRect = UIScreen.main.bounds

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
                    .position(x: screenSize.width * 0.5, y: (self.show_login) ? screenSize.height * 0.452 : screenSize.height * -2)
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
                self.timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
            }
        })
    }
}

struct LoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        LoginFlow()
    }
}
