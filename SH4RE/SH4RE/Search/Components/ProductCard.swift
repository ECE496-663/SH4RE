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
    private let width:CGFloat = 170
    private let height:CGFloat = 175

        
    var body: some View {
        
        ZStack (){
            
            VStack (spacing: 0){
                Image(uiImage: self.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width , height: height)
                    .clipped()
            
                VStack (alignment: .leading) {
                    // Todo: Add a max title length
                    Text(listing.title)
                        .bold()
                    // Todo: Figure out how were doing pricing
                    Text("$\(listing.price) / Day")
                        .font(.caption)
                }
                .padding()
                .frame(width: width, height: 75, alignment: .leading)
                .background(.white)
            }
        }
        .frame(width: width, height: height + 75)
        .background(.white)
        .cornerRadius(20)
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: "20.00")
        ProductCard(listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
    }
}
