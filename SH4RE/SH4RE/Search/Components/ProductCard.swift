//
//  ProductCard.swift
//  SH4RE
//
//  Created by Americo on 2022-11-29.
//

import SwiftUI
import FirebaseAuth

struct FavButtonBounce: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct LandscapeProductCard: View {
    var listing: Listing;
    var image:UIImage
    private let width:CGFloat = screenSize.width * 0.85
    private let height:CGFloat = screenSize.height * 0.1
        
    var body: some View {
        ZStack (alignment: .topTrailing){
            HStack (spacing: 0){
                Image(uiImage: self.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width * 0.4 , height: height)
                    .clipped()
            
                VStack (alignment: .leading) {
                    Text(listing.title)
                        .bold()
                    Text("$\(String(format: "%.2f", listing.price)) / Day")
                        .font(.caption)
                }
                .padding()
                .frame(width: width * 0.6, height: height, alignment: .leading)
                .background(.white)
            }
        }
        .frame(width: width, height: height)
        .background(.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primaryDark, lineWidth: 1)
        )
    }
}

struct ProductCard: View {
    @ObservedObject var favouritesModel: FavouritesModel
    var listing: Listing;
    var image:UIImage
    @State var favourited = false
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
                    Text("$\(String(format: "%.2f", listing.price)) / Day")
                        .font(.caption)
                }
                .padding()
                .frame(width: width, height: 75, alignment: .leading)
                .background(.white)
                
            }
            //Don't show the fav button for their own listing
            if (!(Auth.auth().currentUser?.isAnonymous ?? true) && listing.uid != getCurrentUserUid()) {
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
        }
        .frame(width: width, height: height + 75)
        .background(.white)
        .cornerRadius(20)
        .onReceive(favouritesModel.favourites.publisher, perform:{ _ in
            // In case the card appears before favs are recieved from server
            favourited = favouritesModel.isFavourited(listingID: listing.id)
        })
        .onAppear(perform:{
            favourited = favouritesModel.isFavourited(listingID: listing.id)
        })
    }
}

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let test_listing = Listing(id :"MNizNurWGrjm1sXNpl15", uid: "Cfr9BHVDUNSAL4xcm1mdOxjAuaG2", title:"Test Listing", description: "Test Description", imagepath : ["path"], price: 10, category: "Camera", address: ["latitude": 43.66, "longitude": -79.37])
        ProductCard(favouritesModel: FavouritesModel(), listing: test_listing, image: UIImage(named: "ProfilePhotoPlaceholder")!)
    }
}
