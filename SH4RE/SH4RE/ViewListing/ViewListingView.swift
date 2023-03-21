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
    @Environment(\.presentationMode) var presentationMode
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    
    //parameters passed in from search nav link
    @State var listing: Listing
    var chatLogViewModel: ChatLogViewModel
    @State var listingPaths: [String] = []
    @State var images : [UIImage?] = []
    @State private var showCal = false
    @State private var showPopUp = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleted = false
    
    var numberOfStars: Float = 4
    var hasHalfStar = true
    var numberOfReviews = 3
    @State var numberOfImages = 0
    @State var description:String = ""
    @State var title:String = ""
    @State var price:String = ""
    @State var name:String = ""
    
    @State var availabilityCalendar = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 1)
    @State var startDateText: String = ""
    @State var endDateText: String = ""
    
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
                        .foregroundColor(.darkGrey)
                        .frame(alignment: .leading)
                    HStack {
                        Text("$\(listing.price)")
                            .font(.headline)
                            .bold()
                        Text("/day")
                            .font(.caption)
                            .foregroundColor(.darkGrey)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if (listing.uid != getCurrentUserUid()) {
                Button(action: {
                    showPopUp.toggle()
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
                    .background(startDateText == "" ? Color.grey : Color.primaryDark)
                    .cornerRadius(40)
                    .padding()
                    
                })
                .disabled(startDateText == "")
            }
            else {
                NavigationLink(destination: {
                    CreateListingView(tabSelection: $tabSelection, editListing: $listing)
                }, label: {
                    HStack {
                        Text("Edit")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        Image(systemName: "pencil.tip.crop.circle")
                            .foregroundColor(.white)
                    }
                    .frame(width: screenSize.width * 0.2)
                    .padding()
                    .background(Color.primaryDark)
                    .cornerRadius(40)
                    .padding([.top, .bottom])
                })
                Button(action: {
                    showDeleteConfirmation.toggle()
                }, label: {
                    HStack {
                        Text("Delete")
                            .font(.body)
                            .foregroundColor(.red)
                        
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .frame(width: screenSize.width * 0.2, alignment: .trailing)
                    .padding()
                    .background(Color.backgroundGrey)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(.red, lineWidth: 2)
                    )
                    .padding([.top, .bottom])
                })
            }
        }
        .padding([.horizontal])
        .background(.white)
        .onChange(of: showDeleted, perform: { newVal in
            if (showDeleted) {
                deleteListing(lid: listing.id)
            }
            else {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }
    
    var body: some View {
        
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ImageCarouselView(numberOfImages: self.numberOfImages, isEditable: false) {
                            ForEach(images, id:\.self) { image in
                                HStack {
                                    Image(uiImage: image ?? (UIImage(named: "placeholder") ?? UIImage()))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width * 0.9, height: 250)
                                        .clipped()
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.primaryDark, lineWidth: 3))

                                }
                                .frame(width: geometry.size.width, height: 250)
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
                    if (endDateText == "") {
                        Text("Send request for “\(listing.title)” for \(startDateText)")
                            .fixedSize(horizontal: false, vertical: true)
                            .bold()
                    } else {
                        Text("Send request for “\(listing.title)” for \(startDateText) - \(endDateText)")
                            .fixedSize(horizontal: false, vertical: true)
                            .bold()
                    }
                    Spacer()
                    
                    NavigationLink(destination: MessagesChat(vm:self.chatLogViewModel)) {
                        HStack {
                            Text("Send")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        sendBookingRequest(uid: getCurrentUserUid(), listing_id: self.listing.id, title: listing.title, start: availabilityCalendar.startDate!, end: availabilityCalendar.endDate)
                        availabilityCalendar.startDate = nil
                        availabilityCalendar.endDate = nil
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
                .frame(width: screenSize.width * 0.9, height: 180)
                .background(.white)
                .cornerRadius(8)
                
            }
            PopUp(show: $showDeleteConfirmation) {
                VStack {
                    Text("Delete listing?")
                        .foregroundColor(.primaryDark)
                        .bold()
                        .padding(.bottom)
                    Button(action: {
                        showDeleteConfirmation.toggle()
                        showDeleted.toggle()
                    })
                    {
                        Text("Yes")
                    }
                    .buttonStyle(primaryButtonStyle())
                    Button(action: {
                        showDeleteConfirmation.toggle()
                    })
                    {
                        Text("Cancel")
                    }
                    .buttonStyle(secondaryButtonStyle())
                }
                .padding()
                .frame(width: screenSize.width * 0.9, height: 160)
                .background(.white)
                .cornerRadius(30)
            }
            PopUp(show: $showDeleted) {
                VStack {
                    Text("Post Deleted")
                        .foregroundColor(.primaryDark)
                        .bold()
                        .padding(.bottom)
                    Button(action: {
                        showDeleted.toggle()
                    })
                    {
                        Text("OK")
                    }
                    .buttonStyle(primaryButtonStyle())
                }
                .padding()
                .frame(width: screenSize.width * 0.9, height: 130)
                .background(.white)
                .cornerRadius(30)
            }
        }
        .overlay(bottomBar, alignment: .bottom)
        .onAppear() {
            if (listing.uid == getCurrentUserUid()) {
                fetchSingleListing(lid: listing.id, completion: { result in
                    listing = result
                    availabilityCalendar.disabledDates = result.availability
                    numberOfImages = result.imagepath.count
                    images.removeAll()
                    for path in result.imagepath {
                        let storageRef = Storage.storage().reference(withPath: path)
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
                    
                })
            }
            else {
                availabilityCalendar.disabledDates = listing.availability
                numberOfImages = listing.imagepath.count
                for path in listing.imagepath {
                    let storageRef = Storage.storage().reference(withPath: path)
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
        .sheet(isPresented: $showCal, onDismiss: didDismiss) {
            RKViewController(isPresented: $showCal, rkManager: availabilityCalendar)
        }
    }
    
    func getTextFromDate(date: Date!) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM d"
        return date == nil ? "" : formatter.string(from: date)
    }
    
    func didDismiss() {
        startDateText = self.getTextFromDate(date: self.availabilityCalendar.startDate)
        endDateText = self.getTextFromDate(date: self.availabilityCalendar.endDate)
    }
}

struct ViewListingView_Previews: PreviewProvider {
    static var previewListing = Listing(uid: "123", title: "Sample Listing", description: "", price: "10")
    static var previewChatLogModel = ChatLogViewModel(chatUser: ChatUser(id: "123", uid: "123", name: "Random"))
    
    static var previews: some View {
        ViewListingView(tabSelection: .constant(2), listing: previewListing, chatLogViewModel: previewChatLogModel)
    }
}
