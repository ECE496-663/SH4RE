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
    @EnvironmentObject var currentUser: CurrentUser
    
    //parameters passed in from search nav link
    var listing: Listing
    var chatLogViewModel: ChatLogViewModel
    @State var listingPaths: [String] = []
    @State var images : [UIImage?] = []
    @State private var showCal = false
    @State private var showPopUp = false
    
    var numberOfStars: Float = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    @State var numberOfImages = 0
    @State var dateString:String = ""
    
    @State private var dates: Set<DateComponents> = []
    @StateObject var myRkManager = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 3)
    

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
                        .foregroundColor(.grey)
                        .font(.caption)
                }
                else {
                    Text("Price")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.grey)
                        .frame(alignment: .leading)
                    HStack {
                        Text("$\(listing.price)")
                            .font(.headline)
                            .bold()
                        Text("/day")
                            .font(.caption)
                            .foregroundColor(.grey)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if(myRkManager.selectedDates.isEmpty){
                NavigationLink(destination: MessagesChat(vm:self.chatLogViewModel)) {
                    HStack {
                        Text("Message")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Image(systemName: "message")
                            .foregroundColor(.white)
                    }
                    .frame(alignment: .trailing)
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(40)
                    .padding()
                }
            }else{
                //TODO Front end update to be prettier
                //hopefully say like send request or something
                Button(action: {
                    showPopUp.toggle()
                }, label: {
                    HStack {
                        Text("Send")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Image(systemName: "message")
                            .foregroundColor(.white)
                    }
                    .frame(alignment: .trailing)
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(40)
                    .padding()
                })
            }
        }
        .padding([.horizontal])
        .background(.white)
    }
    
    var body: some View {
        
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ImageCarouselView(numberOfImages: self.numberOfImages, isEditable: false) {
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
                            .foregroundColor(.grey)
                    }
                    .padding([.horizontal])
                    
                    Text(listing.description)
                        .font(.body)
                        .padding([.horizontal])
                        .padding([.top], 10)
                    
                    Button(action: {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        if(myRkManager.selectedDates.count > 1){
                            dateString = dateFormatter.string(from: myRkManager.selectedDates.first!) + " - " + dateFormatter.string(from: myRkManager.selectedDates.last!)
                        }else if(myRkManager.selectedDates.count == 1){
                            dateString = dateFormatter.string(from: myRkManager.selectedDates.first!)
                        }
                        showCal.toggle()
                    }) {
                        HStack {
                            Text("Check Availability")
                                .font(.body)
                                .foregroundColor(.primaryDark)
                            
                            Image(systemName: "calendar")
                                .foregroundColor(.primaryDark)
                        }
                        .padding([.horizontal, .vertical], 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.primaryDark)
                        )
                        .padding()
                        
                    }
                    
                    reviews
                }
            }
            PopUp(show: $showPopUp) {
                VStack(alignment: .leading) {
                    Text("Send request for “\(listing.title)” for the following dates: ").bold()
                    //TODO date string is not showing even though it is updated correctly
                    //I believe this is an issue with how pop up is written since it works when i move text elsewhere
                    //I think we should move the pop up code inside for this case unless anyone know a way
                    Text(dateString)
                    
                    NavigationLink(destination: MessagesChat(vm:self.chatLogViewModel)) {
                        HStack {
                            Text("Send")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        
                        let startDate = myRkManager.selectedDates.count > 0 ? myRkManager.selectedDates[0] : nil
                        let endDate = myRkManager.selectedDates.count > 1 ? myRkManager.selectedDates[myRkManager.selectedDates.count - 1] : nil
                        if(startDate != nil && endDate != nil){
                            sendBookingRequest(uid: getCurrentUserUid(), listing_id: self.listing.id, title: listing.title, start: startDate!, end: endDate!)
                        }else if(startDate != nil){
                            sendBookingRequest(uid: getCurrentUserUid(), listing_id: self.listing.id, title: listing.title, start: startDate!)
                        }else{
                            //TODO add pop up/message
                            //only allow navigation with valid dates
                            print("invalid dates selected")
                        }
                        myRkManager.selectedDates = []
                    })
                    .fontWeight(.semibold)
                    .frame(width: screenSize.width * 0.8, height: 40)
                    .foregroundColor(.white)
                    .background(Color.primaryDark)
                    .cornerRadius(40)
                    
                    Button(action: {
                        showPopUp.toggle()
                    })
                    {
                        Text("Cancel")
                    }
                    .buttonStyle(secondaryButtonStyle())
                }
                .padding()
                .frame(width: 350, height: 180)
                .background(.white)
                .cornerRadius(8)
                
            }
        }
        .overlay(bottomBar, alignment: .bottom)
        .onAppear() {
            myRkManager.disabledDates = listing.availability
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
        .sheet(isPresented: $showCal) {
            RKViewController(isPresented: $showCal, rkManager: myRkManager)
        }
    }
}
