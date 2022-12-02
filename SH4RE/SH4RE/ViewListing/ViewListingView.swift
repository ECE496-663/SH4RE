//
//  ViewListingView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase
import FirebaseStorage

//Stuff to know for database
//ViewListing is passed a listing struct define in ListingViewModel
//We map the fields from the listing struct to class variable in .OnAppear
//View listing is passed and image which is set as the classes image variable being displayed
//if you need to create more variables create filler class variable and we will connect to database in later commit

struct ViewListingView: View {
    
    //parameters passed in from search nav link
    var listing: Listing
    var image: UIImage
    
    let screenSize: CGRect = UIScreen.main.bounds
    var numberOfStars: Float = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    var numberOfImages = 3
    
    var body: some View {
        
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
                    
                    GeometryReader { geometry in
                        ImageCarouselView(numberOfImages: numberOfImages) {
                            ForEach([image, UIImage(named: "ProfilePhotoPlaceholder")!, UIImage(named: "ProfilePhotoPlaceholder")!], id:\.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: 250)
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    }
                    .frame(height: 300)
                                        
                    Text(listing.title)
                        .font(.title)
                        .bold()
                        .padding([.horizontal])
                    
                    HStack {
                        StarsView(numberOfStars: numberOfStars)
                        
                        Text("(\(numberOfReviews) reviews)")
                            .font(.caption)
                            .foregroundColor(Color("TextGrey"))
                    }
                    .padding([.horizontal])
                    
                    Text(listing.description)
                        .font(.body)
                        .padding([.horizontal])
                        .padding([.top], 10)
                    
                    Button(action: {
                        print("Check Availability button clicked")
                    }) {
                        HStack {
                            Text("Check Availability")
                                .font(.body)
                                .foregroundColor(Color("PrimaryDark"))
                            
                            Image(systemName: "calendar")
                                .foregroundColor(Color("PrimaryDark"))
                        }
                        .padding([.horizontal, .vertical], 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color("PrimaryDark"))
                        )
                        .padding()
                        
                    }
                    
                    Text("Reviews (\(numberOfReviews))")
                        .font(.headline)
                        .padding()
                }
            }
        }
        
        ZStack {
            HStack {
                VStack {
                    if (listing.price.isEmpty) {
                        Text("Message user for more pricing info")
                            .foregroundColor(Color("TextGrey"))
                            .font(.caption)
                    }
                    else {
                        Text("Price")
                            .font(.callout)
                            .bold()
                            .foregroundColor(Color("TextGrey"))
                            .frame(alignment: .leading)
                        HStack {
                                Text("$\(listing.price)")
                                    .font(.headline)
                                    .bold()
                                Text("/day")
                                    .font(.caption)
                                    .foregroundColor(Color("TextGrey"))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    print("Message user about \(listing.price)")
                }) {
                    HStack {
                        Text("Message")
                            .font(.body)
                            .foregroundColor(Color("White"))
                        
                        Image(systemName: "message")
                            .foregroundColor(Color("White"))
                    }
                }
                .frame(alignment: .trailing)
                .padding()
                .background(Color("PrimaryDark"))
                .cornerRadius(40)
                .padding()
            }
        }
        .padding([.horizontal])
        .frame(alignment: .bottom)
    }
}

//struct ViewListingView_Previews: PreviewProvider {
    //static var previews: some View {
        //ViewListingView()
    //}
//}
