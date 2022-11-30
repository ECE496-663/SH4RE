//
//  ProductCard.swift
//  SH4RE
//
//  Created by Americo on 2022-11-29.
//

import SwiftUI

struct ProductCard: View {
    var listing: Listing;
    var image:UIImage
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        
        ZStack (alignment: .bottom){
            Image(uiImage: self.image)
                .resizable()
//                .frame(width: 180)
//                .cornerRadius(20)
//                .frame(width: 180)
                .scaledToFill()
            
                
//                .padding()
            VStack (alignment: .leading) {
                // Todo: Add a max title length
                Text(listing.title)
                    .bold()
                // Todo: Figure out how were doing pricing
                Text("\(listing.price) per Day")
                    .font(.caption)
            }
            .padding()
            .frame(width: 180, alignment: .leading)
            .background(.ultraThinMaterial)
        }
        .frame(width: 180, height: 250)
        .cornerRadius(20)
        .shadow(radius: 3)
//        .border(Color("TextGrey"))
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", title:"Test Listing", description: "Test Description", imagepath : "path", price: "$20.00")
        ProductCard(listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
    }
}
