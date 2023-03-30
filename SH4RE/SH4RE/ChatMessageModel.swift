//
//  ChatMessageModel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-19.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
import SwiftUI

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
    let isRequest: Bool
    let listingTitle: String
    let datesRequested: String
    let listingId: String
    let requestId: String
    let isReviewRequest: Bool
}

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    var name: String
}

struct RecentMessage: Identifiable {
    @DocumentID var id: String?
    let text, name: String
    let fromId, toId: String
    let timestamp: Date
    let isRequest: Bool
    let listingTitle: String
    let datesRequested: String
    let listingId: String
    let requestId: String
    let isReviewRequest: Bool
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let email = "email"
    static let uid = "uid"
    static let profileImageUrl = "profileImageUrl"
    static let messages = "messages"
    static let users = "users"
    static let recentMessages = "recent_messages"
}

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
