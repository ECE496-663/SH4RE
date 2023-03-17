//
//  ProductCard.swift
//  SH4RE
//
//  Created by Americo on 2022-11-29.
//

import SwiftUI

struct FavButtonBounce: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ProductCard: View {
    @ObservedObject var favouritesModel: FavouritesModel
    var listing: Listing;
    var image:UIImage
    @State var favourited: Bool
    private let width:CGFloat = 170
    private let height:CGFloat = 175

    init(favouritesModel: FavouritesModel, listing: Listing, image: UIImage) {
        self.favouritesModel = favouritesModel
        self.listing = listing
        self.image = image
        self.favourited = favouritesModel.isFavourited(listingID: listing.id)
    }

    func toggleFav(){
        favourited = favouritesModel.toggleFavourite(listingID: listing.id)
    }
        
    var body: some View {
        
        ZStack (alignment: .topTrailing){
            
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
            Button(action: {toggleFav()}){
                Image(systemName: favourited ? "heart.fill" : "heart")
                    .padding(6)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(50)
                    .padding()
            }
            .buttonStyle(FavButtonBounce())
        }
        .frame(width: width, height: height + 75)
        .background(.white)
        .cornerRadius(20)
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: "20.00")
        ProductCard(favouritesModel: FavouritesModel(), listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
    }
}
