//
//  ViewListingView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ViewListingView: View {
    var listing : Listing
    @State var image1 = UIImage()
    let screenSize: CGRect = UIScreen.main.bounds
    var numberOfStars = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    @State var description:String = ""
    @State var title:String = ""
    
    var reviewers = [
        [
            "name": "Melissa Lim",
            "profilePhoto": UIImage(named: "ProfilePhotoPlaceholder")!,
            "stars": 5
        ],
        [
            "name": "Carson Lander",
            "profilePhoto": UIImage(named: "ProfilePhotoPlaceholder")!,
            "stars": 4
        ],
        [
            "name": "Tony Chan",
            "profilePhoto": UIImage(named: "ProfilePhotoPlaceholder")!,
            "stars": 4
        ]
    ]
    //var hardcoded_listing_id = "MNizNurWGrjm1sXNpl15"
    
    
    
    
    
    var body: some View {
        
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                Image(uiImage: self.image1)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(width: screenSize.width * 0.9, height: 250)
                    .aspectRatio(contentMode: .fill)
                    .border(.black)
                    .padding()
                
                Text(self.title)
                    .font(.title)
                    .padding()
                
                HStack {
                    ForEach(0 ..< self.numberOfStars, id: \.self) { idx in
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
                    
                    Text("(\(self.numberOfReviews) reviews)")
                        .font(.caption)
                }
                .padding()
                
                Text(self.description)
                    .font(.body)
                    .padding()
                        
                
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
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color("PrimaryDark"))
                    )
                    .padding()
                    
                }
                
                Text("Reviews (\(self.numberOfReviews))")
                    .font(.title3)
                    .padding()
                
//                ForEach(reviewers, id: \.self) { reviewer in
//
//                    HStack {
//                        Image(uiImage: reviewer.profilePhoto)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .clipShape(Circle())
//
//                        VStack {
//                            Text(reviewer.name)
//                                .font(.body)
//                        }
//                    }
//                }
            }
        }
        .onAppear(){
            self.description = listing.description
            self.title = listing.title
            let storageRef = Storage.storage().reference().child(listing.imagepath)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error: Image could not download!")
                } else {
                    self.image1 = UIImage(data: data!)!
                }
            }
        }
    }
}

//struct ViewListingView_Previews: PreviewProvider {
    //static var previews: some View {
        //ViewListingView()
    //}
//}
