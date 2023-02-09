//
//  MessageView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-02-09.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == getCurrentUserUid() {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text.replacingOccurrences(of: "\n", with: ""))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text.replacingOccurrences(of: "\n", with: ""))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
