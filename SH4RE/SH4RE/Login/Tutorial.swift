//
//  Tutorial.swift
//  SH4RE
//
//  Created by November on 2023-01-04.
//

import SwiftUI

struct Tutorial: View {
    @Environment(\.showLoginScreen) var showLoginScreen
    @State private var tutorialIndex: Int = 0
    @State private var title: String = ""
    @State private var description: String = ""

    func updateText() {
        switch tutorialIndex {
        case 0:
            title = "Find any kind of household item"
            description = "Welcome to SH4RE, here you can find several household items available to rent. Everything from power tools, outdoors equipment, technology, and so much more!"
        case 1:
            title = "Affordable peer-to-peer rates"
            description = "The items here are listed by users just like you. If you see an item you like, you can make a request to rent it and pick it up directly from the owner."
        case 2:
            title = "Get exclusive access to your community"
            description = "Press the button below to begin SH4RE-ing with your community. You can continue as just a Guest if you want to only take a quick look at what's availble around you.\n\n\n\n"
        default:
                break
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .frame(width: index == tutorialIndex ? 50 : 10, height: 10)
                        .foregroundColor(index == tutorialIndex ? customColours["primaryDark"]! : customColours["grey"]!)
                        .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                        .padding(.bottom, 8)
                        .animation(.spring(), value: UUID())
                }
            }

            Spacer()

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(customColours["primaryDark"]!)
                .frame(maxWidth: screenSize.width * 0.5)
                .multilineTextAlignment(.center)
                .padding()
                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.5)))
                .id(String(tutorialIndex))

            Text(description)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(customColours["darkGrey"]!)
                .frame(maxWidth: screenSize.width * 0.7)
                .multilineTextAlignment(.center)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.5)))
                .id(String(tutorialIndex))

            Spacer()

            if (tutorialIndex != 2) {
                Button(action: {
                    tutorialIndex += 1
                    updateText()
                })
                {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                }
                .frame(width: 100, height: 100)
                .background(customColours["primaryDark"]!)
                .clipShape(Circle())
            }
            Button(action: {
                showLoginScreen!()
            })
            {
                Text("Get Started")
                    .fontWeight(.bold)
                    .frame(width: (tutorialIndex == 2) ? screenSize.width * 0.8 : 0, height: (tutorialIndex == 2) ? 30 : 0)
                    .padding()
                    .foregroundColor(.white)
                    .background((tutorialIndex == 2) ? customColours["primaryDark"]! : .white)
                    .cornerRadius(40)
                    .animation(.spring(), value: UUID())
            }
        }
        .onAppear(perform: updateText)
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        Tutorial()
    }
}
