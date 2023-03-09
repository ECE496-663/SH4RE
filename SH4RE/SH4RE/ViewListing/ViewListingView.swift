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
    @State var listingPaths: [String] = []
    @State var images : [UIImage?] = []
    @State private var showCal = false
    @State private var showPopUp = false
    
    var numberOfStars: Float = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    @State var numberOfImages = 0
    @State var description:String = ""
    @State var title:String = ""
    @State var price:String = ""
    @State var name:String = ""
        
    var availabilityCalendar = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 1)

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
            //                        NavigationLink(destination: MessagesChat(vm:ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: name)))) {
            //                            HStack {
            //                                Text("Message")
            //                                    .font(.body)
            //                                    .foregroundColor(.white)
            //
            //                                Image(systemName: "message")
            //                                    .foregroundColor(.white)
            //                            }
            //                        }
            //                        .frame(alignment: .trailing)
            //                        .padding()
            //                        .background(Color.primaryDark)
            //                        .cornerRadius(40)
            //                        .padding()
            
            Button(action: {
                var startDateText = self.getTextFromDate(date: self.availabilityCalendar.startDate)
                var endDateText = self.getTextFromDate(date: self.availabilityCalendar.endDate)
                
                print(startDateText)
                print(endDateText)
                if (startDateText != "" && endDateText != "") {
                    showPopUp.toggle()
                }
            }, label: {
                HStack {
                    Text("Message")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Image(systemName: "message")
                        .foregroundColor(.white)
                }
                .frame(alignment: .trailing)
                .padding()
                .background(self.getTextFromDate(date: self.availabilityCalendar.startDate) == "" ? Color.grey : Color.primaryDark)
                .cornerRadius(40)
                .padding()
            })
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
                    Text("Send request for “\(listing.title)” for the following days:").bold()
//                    ForEach(dates.sorted{$0.date! < $1.date!}, id: \.self) { date in
//                        let res = String(date.year!) + "-" + String(date.month!) + "-" + String(date.day!)
//
//                        Text("\(res)")
//                    }
                    HStack {
                        Text("hi \(self.getTextFromDate(date: self.availabilityCalendar.startDate))")
                        Text(" - ")
                        Text(self.getTextFromDate(date: self.availabilityCalendar.endDate))
                    }
                    
                    NavigationLink(destination: MessagesChat(vm:ChatLogViewModel(chatUser: ChatUser(id: listing.uid,uid: listing.uid, name: name)))) {
                        HStack {
                            Text("Send")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
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
            availabilityCalendar.disabledDates = [Date().addingTimeInterval(60*60*24*4), Date().addingTimeInterval(60*60*24*5), Date().addingTimeInterval(60*60*24*6)] // here is where we would add the disabled dates
            
            numberOfImages = listing.imagepath.count
            for path in listing.imagepath {
                let storageRef = Storage.storage().reference(withPath: path)
                //Download in Memory with a Maximum Size of 1MB (1 * 1024 * 1024 Bytes):
//                storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
//                    if let error = error {
//                        print (error)
//                    } else {
//                        //Image Returned Successfully:
//                        let image = UIImage(data: data!)
//                        images.append(image)
//                    }
//                }
            }
            getUserName(uid: listing.uid, completion: { ret in
                name = ret
            })
        }
        .sheet(isPresented: $showCal) {
            RKViewController(isPresented: $showCal, rkManager: availabilityCalendar)
        }
    }
    
    func getTextFromDate(date: Date!) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM d"
        return date == nil ? "" : formatter.string(from: date)
    }
}

struct ViewListingView_Previews: PreviewProvider {
    static var previewListing = Listing(uid: "123", title: "Sample Listing", description: "", price: "10")
    
    static var previews: some View {
        ViewListingView(tabSelection: .constant(2), listing: previewListing)
    }
}
