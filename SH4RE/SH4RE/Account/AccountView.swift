//
//  AccountView.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2022-11-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct ParentAccountKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}
extension EnvironmentValues {
    var showAccountScreen: (() -> Void)? {
        get { self[ParentAccountKey.self] }
        set { self[ParentAccountKey.self] = newValue }
    }
}

struct AccountView: View {
    @Binding var tabSelection: Int
    @EnvironmentObject var currentUser: CurrentUser
    @State private var showTutorial:Bool = false;
    @State private var profilePicture:UIImage = UIImage(named: "ProfilePhotoPlaceholder")!
    @State private var name:String = "Placeholder"
    @State var numberOfStars: Float = 0
    
    private var profile: some View {
        VStack {
            Image(uiImage: profilePicture)
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: screenSize.width * 0.1, maxHeight: screenSize.height * 0.1)
            Text(name)
                .font(.body)
            StarsView(numberOfStars: numberOfStars)
        }
        .frame(height: screenSize.height * 0.2)
    }
    
    private var menu: some View {
        VStack {
            NavigationLink(destination: {
                MyListingsView(tabSelection: $tabSelection)
                    .environmentObject(currentUser)
            }, label: {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.primaryDark)
                        .frame(width: screenSize.width * 0.1)
                    Text("My Listings")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: screenSize.width * 0.3, alignment: .leading)
                }
                .padding(.bottom)
            })
            NavigationLink(destination: {
                EditAccountView()
            }, label: {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.primaryDark)
                        .frame(width: screenSize.width * 0.1)
                    Text("Edit Account")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: screenSize.width * 0.3, alignment: .leading)
                }
                .padding(.bottom)
            })
            NavigationLink(destination: {
                ReviewsView()
            }, label: {
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(.primaryDark)
                        .frame(width: screenSize.width * 0.1)
                    Text("Reviews")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: screenSize.width * 0.3, alignment: .leading)
                }
                .padding(.bottom)
            })
            NavigationLink(destination: {
                FavouritesView()
            }, label: {
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.primaryDark)
                        .frame(width: screenSize.width * 0.1)
                    Text("Favourites")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: screenSize.width * 0.3, alignment: .leading)
                }
                .padding(.bottom)
            })
            Button(action: {
                showTutorial.toggle()
            }, label: {
                HStack {
                    Image(systemName: "questionmark.bubble")
                        .foregroundColor(.primaryDark)
                        .frame(width: screenSize.width * 0.1)
                    Text("Help")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: screenSize.width * 0.3, alignment: .leading)
                }
                .padding(.bottom)
            })
        }
        .frame(width: screenSize.width * 0.9, alignment: .leading)
    }
    func showAccountScreen() {
        showTutorial.toggle()
    }
    
    var body: some View {
        ZStack {
            Color.backgroundGrey.ignoresSafeArea()
            
            if (currentUser.isGuest()) {
                GuestView(tabSelection: $tabSelection).environmentObject(currentUser)
            }
            else if (showTutorial) {
                TutorialView()
                    .environment(\.showLoginScreen, showAccountScreen)
            }
            else {
                NavigationStack {
                    VStack {
                        Text("My Account")
                            .font(.title.bold())
                            .frame(width: screenSize.width * 0.9, alignment: .leading)
                        profile
                            .padding(.bottom)
                        
                        menu
                        
                        Spacer()
                        
                        Button(action: {
                            tabSelection = 1
                            do {
                                try Auth.auth().signOut()
                            }
                            catch {
                                print(error)
                            }
                            currentUser.hasLoggedIn = false
                            //Remove some user specific info
                            UserDefaults.standard.setValue([""], forKey: "RecentSearchQueries")
                        })
                        {
                            Text("Logout")
                        }
                        .buttonStyle(secondaryButtonStyle())
                        Spacer()
                    }
                    .onAppear() {
                        getCurrentUser() {(result) in
                            name = result.name
                            let storageRef = Storage.storage().reference(withPath: result.pfpPath)
                            storageRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
                                if let error = error {
                                    print (error)
                                } else {
                                    profilePicture = UIImage(data: data!) ?? UIImage(named: "ProfilePhotoPlaceholder")!
                                }
                            }
                        }
                        
                        getUserRating(uid: getCurrentUserUid(), completion: { rating in
                            numberOfStars = rating
                        })
                    }
                }
                .accentColor(.primaryDark)
            }
        }
    }
}
