//
//  ReviewsView.swift
//  SH4RE
//
//  Created by March on 2023-03-19.
//

import SwiftUI

struct ReviewsView: View {
    @State var allReviews = [Review]()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.backgroundGrey.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Reviews (\(allReviews.count))")
                    .font(.headline)
                    .padding()
                
                ForEach(allReviews) { review in
                    ReviewView(reviewName: review.name, reviewRating: review.rating as Float, reviewDescription: review.description, reviewUID: review.uid)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Reviews")
        .onAppear() {
            getUserReviews(uid: getCurrentUserUid(), completion: { reviews in
                allReviews = reviews
            })
        }
        
        
    }
}

struct ReviewsView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewsView()
    }
}
