//
//  Stars.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-30.
//

import SwiftUI

struct StarsView: View {
    private var numberOfStars: Int
    private var hasHalfStar: Bool
    private var remainingStars: Int
    
    init(numberOfStars: Float) {
        self.numberOfStars = Int(numberOfStars)
        self.hasHalfStar = round(numberOfStars.truncatingRemainder(dividingBy: 1)) == 1 ? true : false
        
        self.remainingStars = self.hasHalfStar ? 5 - self.numberOfStars - 1 : 5 - self.numberOfStars
    }
    
    var body: some View {
        HStack {
            ForEach(0 ..< numberOfStars, id: \.self) { idx in
                Label("star\(idx)", systemImage: "star.fill")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            if (self.hasHalfStar) {
                Label("half-star", systemImage: "star.fill.left")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            ForEach(0 ..< remainingStars, id: \.self) { idx in
                Label("star\(idx)", systemImage: "star")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
    }
}

struct Stars_Previews: PreviewProvider {
    static var previews: some View {
        StarsView(numberOfStars: 3)
    }
}
