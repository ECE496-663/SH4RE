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
    @Binding var tabSelection: Int
    
    
    //parameters passed in from search nav link
    var listing: Listing
    @State var listingPaths: [String] = []
    @State var images : [UIImage?] = []
    @State private var showCal = false

    
    var numberOfStars: Float = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    @State var numberOfImages = 0
    @State var description:String = ""
    @State var title:String = ""
    @State var price:String = ""
    @State private var dates: Set<DateComponents> = []
    
    private var reviews: some View {
        VStack(alignment: .leading) {
            Text("Reviews (\(numberOfReviews))")
                .font(.headline)
                .padding()
            
            HStack(alignment: .top) {
                Image("placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text("Melissa Lim")
                        .font(.body)
                    
                    StarsView(numberOfStars: 3.5)
                    Text("Fusce non arcu non nunc ultrices hendrerit. In libero risus, auctor ac turpis in, venenatis tempus erat tincidunt et lorem ipsum.")
                        .font(.footnote)
                }
                
            }
            .padding([.horizontal])
        }
        
    }
    
    private var bottomBar: some View {
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
            NavigationLink(destination: MessagesInboxView(tabSelection: $tabSelection)) {
                Button(action: { tabSelection = 4 }) {
                    HStack {
                        Text("Message")
                            .font(.body)
                            .foregroundColor(Color("White"))
                        
                        Image(systemName: "message")
                            .foregroundColor(Color("White"))
                    }
                }
            }
            .frame(alignment: .trailing)
            .padding()
            .background(Color("PrimaryDark"))
            .cornerRadius(40)
            .padding()
        }
        .padding([.horizontal])
        .background(Color("White"))
    }

    
    var body: some View {
        
        ZStack {
            Color("BackgroundGrey").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ImageCarouselView(numberOfImages: self.numberOfImages) {
                        ForEach(images, id:\.self) { image in
                            Image(uiImage: image ?? (UIImage(named: "placeholder") ?? UIImage()))
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
                        showCal.toggle()
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
                    
                    reviews
                }
            }
            PopUp(show: $showCal) {
                DatePicker(dates: dates)
            }
        }
        .overlay(
            bottomBar, alignment: .bottom)
        .onAppear() {
            print("\(listing)")

            price = listing.price
            numberOfImages = listing.imagepath.count
            for path in listing.imagepath{
                let storageRef = Storage.storage().reference(withPath: path)
                //Download in Memory with a Maximum Size of 1MB (1 * 1024 * 1024 Bytes):
                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                    if let error = error {
                        print (error)
                    } else {
                        //Image Returned Successfully:
                        let image = UIImage(data: data!)
                        images.append(image)
                    }
                }
            }
        }
        
    }
}

//struct ViewListingView_Previews_helper: View {
//    @State private var tabSelection = 1
//    var listing : Listing = Listing(id: "3rWyQLjIYsIA7wlrQ37r", title: "Camera", description: "This is a very fancy DSLR camera", imagepath: ["listingimages/3rWyQLjIYsIA7wlrQ37r/1.jpg", "listingimages/3rWyQLjIYsIA7wlrQ37r/2.jpg"], price: "25", imageDict: UIImage(named: "placeholder")!)
//
//    var body: some View {
//        ViewListingView(tabSelection: $tabSelection, listing: listing)
//    }
//}
//
//struct ViewListingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewListingView_Previews_helper()
//    }
//}
