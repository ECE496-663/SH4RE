//
//  PopUp.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-10.
//

import SwiftUI

struct PopUp<Content: View>: View {
    @Binding var show: Bool
    private var content: Content
    
    init(show: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._show = show
        self.content = content()
    }
    
    var body: some View {
        if show {
            ZStack {
                Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)
            }
            .onTapGesture {
                print("heyyy")
                show = false
            }
            
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    self.content
                }
                .frame(maxWidth: 350, maxHeight: 350)
            }
        }
    }
}
