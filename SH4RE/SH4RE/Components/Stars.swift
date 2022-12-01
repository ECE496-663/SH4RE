//
//  Stars.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-30.
//

import SwiftUI

struct StarsView: View {
    private var numberOfStars: Float
    private var hasHalfStar: Bool
    
    init(numberOfStars: Float) {
        self.numberOfStars = numberOfStars
        self.hasHalfStar = round(numberOfStars.truncatingRemainder(dividingBy: 1)) == 1 ? true : false
    }
    
    var body: some View {
        ForEach(0 ..< Int(numberOfStars), id: \.self) { idx in
            Label("star\(idx)", systemImage: "star.fill")
                .labelStyle(.iconOnly)
                .foregroundColor(Color("Yellow"))
                .font(.system(size: 12))
        }
        
        if (self.hasHalfStar) {
            Label("half-star", systemImage: "star.fill.left")
                .labelStyle(.iconOnly)
                .foregroundColor(Color(UIColor(named: "Yellow")!))
                .font(.system(size: 12))
        }
    }
}

struct Stars_Previews: PreviewProvider {
    static var previews: some View {
        StarsView(numberOfStars: 3)
    }
}
