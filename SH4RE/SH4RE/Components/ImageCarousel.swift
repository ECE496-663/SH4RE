//
//  ImageCarousel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-30.
//

import SwiftUI

struct ImageCarouselView<Content: View>: View {
    private var numberOfImages: Int
    private var content: Content
    @State private var currentIndex: Int = 0
    @State private var offset = CGSize.zero

    init(numberOfImages: Int, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    self.content
                }
                .frame(width: geometry.size.width, height: 300, alignment: .leading)
                .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
                .animation(.spring())
                .onChange(of: self.numberOfImages) { newItem in
                    Task {
                        self.currentIndex = (self.numberOfImages == 6) ? 0 : self.currentIndex
                        self.currentIndex = (self.numberOfImages - self.currentIndex != 1) ? 0 : self.currentIndex
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            if offset.width > 20 {
                                if self.currentIndex > 0 {
                                    self.currentIndex -= 1
                                }
                            }
                            else if offset.width < 20 {
                                if self.currentIndex < numberOfImages - 1 && self.currentIndex < 4 {
                                    self.currentIndex += 1
                                }
                            }
                            else {
                                offset = .zero
                            }
                        }
                )
                HStack(spacing: 3) {
                    let scroll_offset = (numberOfImages == 6) ? 1 : 0
                    ForEach(0..<self.numberOfImages - scroll_offset, id: \.self) { index in
                        Capsule()
                            .frame(width: index == self.currentIndex ? 50 : 10, height: 10)
                            .foregroundColor(index == self.currentIndex ? Color.init(UIColor(named: "PrimaryDark")!) : .white)
                            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                            .padding(.bottom, 8)
                            .animation(.spring())
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }
}

