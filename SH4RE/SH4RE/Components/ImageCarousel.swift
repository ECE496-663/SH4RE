//
//  ImageCarousel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-30.
//

import SwiftUI

struct ImageCarouselView<Content: View>: View {
    @Environment(\.deleteImage) var deleteImage
    private var numberOfImages: Int
    private var isEditable: Bool
    private var content: Content
    @State private var currentIndex: Int = 0
    @State private var offset = CGSize.zero
    @State private var show:Bool = true;

    init(numberOfImages: Int, isEditable: Bool, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.isEditable = isEditable
        self.content = content()
    }

    func animateCloseButton () {
        show.toggle()
        let delay = 500 // seconds to wait before firing
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
            // set your var here
            show.toggle()
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    self.content
                }
                .frame(width: geometry.size.width, height: 300, alignment: .leading)
                .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
                .animation(.spring(), value: UUID())
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
                                    animateCloseButton()
                                    self.currentIndex -= 1
                                }
                            }
                            else if offset.width < 20 {
                                if self.currentIndex < numberOfImages - 1 && self.currentIndex < 4 {
                                    animateCloseButton()
                                    self.currentIndex += 1
                                }
                            }
                            else {
                                offset = .zero
                            }
                        }
                )
                HStack(spacing: 3) {
                    let scrollOffset = (numberOfImages == 6) ? 1 : 0
                    ForEach(0..<self.numberOfImages - scrollOffset, id: \.self) { index in
                        Capsule()
                            .frame(width: index == self.currentIndex ? 50 : 10, height: 10)
                            .foregroundColor(index == self.currentIndex ? .primaryDark : .white)
                            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
                            .padding(.bottom, 8)
                            .animation(.spring(), value: UUID())
                    }
                }
            }
        }
        if (currentIndex != numberOfImages - 1 && isEditable && show) {
            Button(action: {
                self.deleteImage!(currentIndex)
            }) {
                ZStack {
                    Circle()
                        .fill(Color.primaryDark)
                        .frame(width: 25, height: 25)
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding([.trailing, .leading, .top], 8)
                .contentShape(Circle())
            }
        }
    }
}
