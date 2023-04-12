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
    @ObservedObject var favouritesModel: FavouritesModel
    
    //parameters passed in from search nav link
    @State var listing: Listing
    var chatLogViewModel: ChatLogViewModel
    @State var listingPaths: [String] = []
    @State var images : [UIImage?] = []
    @State private var showCal = false
    @State private var showPopUp = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleted = false
    @State private var showPromoConfirmation = false
    @State private var showPromoted = false
    @State private var showVerifyEmailPopUp = false
    
    @State var numberOfStars: Float = 0
    @State var allReviews = [Review]()
    @State var numberOfImages = 0
    @State var description:String = ""
    @State var title:String = ""
    @State var price:String = ""
    @State var name:String = ""
    
    @State var availabilityCalendar = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*90), mode: 1)
    @State var startDateText: String = ""
    @State var endDateText: String = ""
    
    private var reviews: some View {
        VStack(alignment: .leading) {
            Text("Reviews (\(allReviews.count))")
                .font(.headline)
                .padding()
            
            ForEach(allReviews) { review in
                ReviewView(reviewName: review.name, reviewRating: review.rating as Float, reviewDescription: review.description, reviewUID: review.uid, reviewProfilePic:review.profilePic)
            }
        }
    }
    
    private var bottomBar: some View {
        HStack {
            VStack (alignment: .leading){
                Text("Price")
                    .font(.callout)
                    .bold()
                    .foregroundColor(.darkGrey)
                    .frame(alignment: .leading)
                HStack {
                    Text("$\(String(format: "%.2f", listing.price))")
                        .font(.headline)
                        .bold()
                    Text("/ day")
                        .font(.caption)
                        .foregroundColor(.darkGrey)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if (listing.uid != getCurrentUserUid()) {
                Button(action: {
                    if (currentUser.isEmailVerified()) {
                        showPopUp.toggle()
                    } else {
                        showVerifyEmailPopUp.toggle()
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
                    .background(Color.primaryDark)
                    .cornerRadius(40)
                    .padding()
                    
                })
            }
            else {
                if (listing.sponsored == 1) {
                    Button(action: {}, label: {
                        HStack {
                            Text("Promoted")
                                .font(.body)
                                .foregroundColor(.green)
                                .lineLimit(nil)
                        }
                        .frame(alignment: .center)
                        .padding()
                        .background(Color.backgroundGrey)
                        .cornerRadius(40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(.green, lineWidth: 2)
                        )
                        .padding(.vertical)
                    }).disabled(true)
                }
                else {
                    Button(action: {
                        showPromoConfirmation.toggle()
                    }, label: {
                        HStack {
                            Text("Promo")
                                .font(.body)
                                .foregroundColor(.white)
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.white)
                        }
                        .frame(alignment: .center)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(40)
                        .padding(.vertical)
                    })
                }
                NavigationLink(destination: {
                        CreateListingView(tabSelection: $tabSelection, editListing: $listing)
                    }, label: {
                        Image(systemName: "pencil.tip.crop.circle")
                            .foregroundColor(.white)
                            .frame(alignment: .center)
                            .padding()
                            .background(Color.primaryDark)
                            .cornerRadius(40)
                            .padding(.vertical)
                    })
                Button(action: {
                        showDeleteConfirmation.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .frame(alignment: .center)
                        .padding()
                        .background(Color.backgroundGrey)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(.red, lineWidth: 2)
                        )
                        .padding(.vertical)
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
            
            ScrollView (showsIndicators: false) {
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
                        
                        Text("(\(allReviews.count) reviews)")
                            .font(.caption)
                            .foregroundColor(.darkGrey)
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
                    
                    Spacer().frame(height: 100)
                }
            }

            bottomBar
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            
            sendMessagePopUp
            verifyEmailPopUp
            showDeleteConfirmationPopUp
            showDeletedPopUp
            showPromoConfirmationPopUp
            showPromotedPopUp
        }
        .onAppear() {
            fetchSingleListing(lid: listing.id, completion: { result in
                 listing = result
                 availabilityCalendar.disabledDates = result.availability
                 numberOfImages = result.imagepath.count
                 images.removeAll()
                 for path in result.imagepath {
                     let storageRef = Storage.storage().reference(withPath: path)
                     storageRef.getData(maxSize: 1 * 1024 * 1024 as Int64) { [self] data, error in
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

            getListingReviews(uid: listing.uid, lid: listing.id, completion: { reviews in
                allReviews = reviews
            })
            
            getListingRating(uid: listing.uid, lid: listing.id, completion:{ rating in
                numberOfStars = rating
            })
        }
        .sheet(isPresented: $showCal, onDismiss: didDismiss) {
            RKViewController(isPresented: $showCal, rkManager: availabilityCalendar)
        }
    }
    
    private var verifyEmailPopUp: some View {
        PopUp(show: $showVerifyEmailPopUp) {
            VStack {
                Text("You must verify your email before messaging users.")
                    .bold()
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    showVerifyEmailPopUp.toggle()
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
    
    private var sendMessagePopUp: some View {
        PopUp(show: $showPopUp) {
            VStack(alignment: .leading) {
                if (startDateText == "" && endDateText == "") {
                    Text("Send message about “\(listing.title)”?")
                        .fixedSize(horizontal: false, vertical: true)
                        .bold()
                }
                else if (endDateText == "") {
                    Text("Send request for “\(listing.title)” for \(startDateText)")
                        .fixedSize(horizontal: false, vertical: true)
                        .bold()
                } else {
                    Text("Send request for “\(listing.title)” for \(startDateText) - \(endDateText)")
                        .fixedSize(horizontal: false, vertical: true)
                        .bold()
                }
                Spacer()
                
                NavigationLink(destination: MessagesChat(vm:self.chatLogViewModel, favouritesModel: favouritesModel, tabSelection: $tabSelection)) {
                    HStack {
                        Text("Send")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }.simultaneousGesture(TapGesture().onEnded {

                    if (startDateText != "") {
                        sendBookingRequest(uid: getCurrentUserUid(), listing_id: self.listing.id, title: self.listing.title, start: availabilityCalendar.startDate!, end: availabilityCalendar.endDate)
                    }
                    
                    self.chatLogViewModel.fetchMessages()
                    availabilityCalendar.startDate = nil
                    availabilityCalendar.endDate = nil
                    
                    showPopUp.toggle()
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
    }
    
    private var showDeleteConfirmationPopUp: some View {
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
    }
    
    private var showDeletedPopUp: some View {
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
    
    private var showPromoConfirmationPopUp: some View {
        PopUp(show: $showPromoConfirmation) {
            VStack {
                Text("Promote listing?")
                    .foregroundColor(.primaryDark)
                    .bold()
                    .padding(.bottom, 5)
                Text("This listing will appear at the top of search results for one week.\n Would you like to promote?")
                    .foregroundColor(.black)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: {
                    sponsorListing(lid: listing.id)
                    listing.sponsored = 1
                    showPromoConfirmation.toggle()
                    showPromoted.toggle()
                })
                {
                    Text("Pay $10")
                }
                .buttonStyle(primaryButtonStyle())
                Button(action: {
                    showPromoConfirmation.toggle()
                })
                {
                    Text("Cancel")
                }
                .buttonStyle(secondaryButtonStyle())
            }
            .padding()
            .frame(width: screenSize.width * 0.9, height: 260)
            .background(.white)
            .cornerRadius(30)
        }
    }
    
    private var showPromotedPopUp: some View {
        PopUp(show: $showPromoted) {
            VStack {
                Text("Post has been Promoted!")
                    .foregroundColor(.primaryDark)
                    .bold()
                    .padding(.bottom)
                Button(action: {
                    showPromoted.toggle()
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
    static var previewListing = Listing(id :"ZIRtdco4Qo6elzHP8AMH", uid: "Y4YBHDZDMEVo9yMVzGgBoVw2ZpH2", title:"Test Listing", description: "Test Description", imagepath : [
        "listingimages/LZG4crHPdpC44A7wVGq7/1.jpg"], price: 20.0, category: "Camera", address: ["latitude": 43.66, "longitude": -79.37], ownerName: "Bob")
    
    static var previewChatLogModel = ChatLogViewModel(chatUser: ChatUser(id: "Y4YBHDZDMEVo9yMVzGgBoVw2ZpH2", uid: "Y4YBHDZDMEVo9yMVzGgBoVw2ZpH2", name: "Random"))
    
    static var previews: some View {
        ViewListingView(tabSelection: .constant(2), favouritesModel: FavouritesModel(), listing: previewListing, chatLogViewModel: previewChatLogModel)
    }
}
