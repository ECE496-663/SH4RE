//
//  Review.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-03-27.
//

import SwiftUI

struct ReviewView: View {
    private var reviewName: String
    private var reviewRating: Float
    private var reviewDescription: String
    
    init(reviewName: String, reviewRating: Float, reviewDescription: String) {
        self.reviewName = reviewName
        self.reviewRating = reviewRating
        self.reviewDescription = reviewDescription
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image("placeholder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(reviewName)
                    .font(.body)
                
                StarsView(numberOfStars: reviewRating)
                Text(reviewDescription)
                    .font(.footnote)
            }
            
        }
        .padding([.horizontal])
    }
}

struct Review_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(reviewName: "John Doe", reviewRating: 4.0, reviewDescription: "Super easy interaction and exchange. Product exactly as described.")
    }
}
