//
//  Review.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-03-27.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ReviewView: View {
    private var reviewName: String
    private var reviewRating: Float
    private var reviewDescription: String
    private var reviewUID: String
    @State var profilePicture: UIImage
    
    init(reviewName: String, reviewRating: Float, reviewDescription: String, reviewUID: String) {
        self.reviewName = reviewName
        self.reviewRating = reviewRating
        self.reviewDescription = reviewDescription
        self.reviewUID = reviewUID
        self.profilePicture = UIImage(named: "ProfilePhotoPlaceholder")!
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: profilePicture)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(reviewName)
                    .font(.body)
                    .padding(.bottom, 4)
                
                StarsView(numberOfStars: reviewRating)
                    
                Text(reviewDescription)
                    .font(.footnote)
                    .padding(.top, 4)
                    
            }
            
        }
        .padding([.horizontal])
        .padding(.bottom, 8)
        .onAppear(){
            //            getUser(uid: reviewUID) {(result) in
            //                let storageRef = Storage.storage().reference(withPath: result.pfpPath)
            //                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
            //                    if let error = error {
            //                        print (error)
            //                    } else {
            //                        profilePicture = UIImage(data: data!) ?? UIImage(named: "ProfilePhotoPlaceholder")!
            //                    }
            //                }
            //            }
        }
    }
}

struct Review_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(reviewName: "John Doe", reviewRating: 4.0, reviewDescription: "Super easy interaction and exchange. Product exactly as described.", reviewUID: "123")
        ReviewView(reviewName: "John Doe", reviewRating: 4.0, reviewDescription: "Super easy interaction and exchange. Product exactly as described.", reviewUID: "123")
        ReviewView(reviewName: "John Doe", reviewRating: 4.0, reviewDescription: "Super easy interaction and exchange. Product exactly as described.", reviewUID: "123")
    }
}
