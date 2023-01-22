////
////  RatingPicker.swift
////  SH4RE
////
////  Created by Americo on 2023-01-19.
////

import SwiftUI
struct RatingsView: View {
    let ratingsArray: [Double]
    let starColor: Color
    @Binding var rating: Double
    
    init(rating: Binding<Double>, maxRating: Int = 5, starColor: Color = .yellow) {
        _rating = rating
        ratingsArray = Array(stride(from: 0.0, through: Double(max(1, maxRating)), by: 0.5))
        self.starColor = starColor
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(ratingsArray, id: \.self) { ratingElement in
                    if ratingElement > 0 {
                        if Int(exactly: ratingElement) != nil && ratingElement <= rating {
                            // Full Star
                            Image(systemName: "star.fill")
                                .foregroundColor(starColor)
                        } else if Int(exactly: ratingElement) == nil && ratingElement == rating {
                            // For .5 star
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray)
                                .overlay(
                                    // Overlay half of a filled star overtop the grey
                                    GeometryReader { reader in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(starColor)
                                            .frame(width: (reader.size.width*0.5), alignment: .leading)
                                            .clipped()
                                    }
                                )
                        } else if Int(exactly: ratingElement) != nil && rating + 0.5 != ratingElement {
                            // Empty Star
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .overlay(
                //This is the invisible slider that sits on top of the stars, allowing users to slide to the number of stars they want, and click to the star rating they want
                GeometryReader { geometry in
                    let closedRange = 0.0...ratingsArray.last!
                    Slider(value: $rating, in: closedRange, step: 0.5)
                        .tint(.clear)
                        .opacity(0.01)
                        .gesture(DragGesture(minimumDistance: 0).onChanged{ value in
                            let percent = min(max(0, Float(value.location.x / geometry.size.width * 1)), 1)
                            let newValue = (closedRange).lowerBound + ceil(Double(percent) * ((closedRange.upperBound - closedRange.lowerBound)*2))/2
                            $rating.wrappedValue = newValue
                            print(newValue)
                        })
                }
            )
        }
        .onAppear {
            rating = Int(exactly: rating) != nil ? rating : Double(Int(rating)) + 0.5
        }
    }
    
}


struct ratingPickerView_PreviewHelper: View {
    @State private var ratingDoub = 3.2

    var body: some View {
        VStack {
            RatingsView(rating: self.$ratingDoub)
            Text(String(ratingDoub))
        }
    }
}

struct FiveStarView_Previews: PreviewProvider {
    static var previews: some View {
        ratingPickerView_PreviewHelper()
    }
}
