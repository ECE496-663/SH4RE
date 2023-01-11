//
//  PopUp.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-10.
//

import SwiftUI

struct PopUp<Content: View>: View {
    private var show: Bool
    private var content: Content

    
    init(show: Bool, @ViewBuilder content: () -> Content) {
        self.show = show
        self.content = content()
    }
    
    var body: some View {
        ZStack {
                if show {
                    Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)

                    
                    VStack(alignment: .center, spacing: 0) {
                        self.content
                    }
                    .frame(maxWidth: 350, maxHeight: 350)
                }
            }
        }
    }
