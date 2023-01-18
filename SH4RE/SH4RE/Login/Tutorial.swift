//
//  Tutorial.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct Tutorial: View {
    @Environment(\.showLoginScreen) var showLoginScreen
    @State private var tutorial_index: Int = 0
    @State private var title: String = ""
    @State private var description: String = ""

    func updateText() {
        switch self.tutorial_index {
        case 0:
            self.title = "Find any kind of household item"
            self.description = "Welcome to SH4RE, here you can find several household items available to rent. Everything from power tools, outdoors equipment, technology, and so much more!"
        case 1:
            self.title = "Affordable peer-to-peer rates"
            self.description = "The items here are listed by users just like you. If you see an item you like, you can make a request to rent it and pick it up directly from the owner."
        case 2:
            self.title = "Get exclusive access to your community"
            self.description = "Press the button below to begin SH4RE-ing with your community. You can continue as just a Guest if you want to only take a quick look at what's availble around you.\n\n\n\n"
        default:
                break
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .frame(width: index == self.tutorial_index ? 50 : 10, height: 10)
                        .foregroundColor(index == self.tutorial_index ? Color.init(UIColor(named: "PrimaryDark")!) : Color.init(UIColor(named: "Grey")!))
                        .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                        .padding(.bottom, 8)
                        .animation(.spring(), value: UUID())
                }
            }

            Spacer()

            Text(self.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.init(UIColor(named: "PrimaryDark")!))
                .frame(maxWidth: screenSize.width * 0.5)
                .multilineTextAlignment(.center)
                .padding()
                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.5)))
                .id(String(self.tutorial_index))

            Text(self.description)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.init(UIColor(named: "DarkGrey")!))
                .frame(maxWidth: screenSize.width * 0.7)
                .multilineTextAlignment(.center)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.5)))
                .id(String(self.tutorial_index))

            Spacer()

            if (self.tutorial_index != 2) {
                Button(action: {
                    self.tutorial_index += 1
                    self.updateText()
                })
                {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                }
                .frame(width: 100, height: 100)
                .background(Color.init(UIColor(named: "PrimaryDark")!))
                .clipShape(Circle())
            }
            Button(action: {
                self.showLoginScreen!()
            })
            {
                Text("Get Started")
                    .fontWeight(.bold)
                    .frame(width: (self.tutorial_index == 2) ? screenSize.width * 0.8 : 0, height: (self.tutorial_index == 2) ? 30 : 0)
                    .padding()
                    .foregroundColor(.white)
                    .background((self.tutorial_index == 2) ? Color.init(UIColor(named: "PrimaryDark")!) : .white)
                    .cornerRadius(40)
                    .animation(.spring(), value: UUID())
            }
        }
        .onAppear(perform: self.updateText)
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
    }
}
