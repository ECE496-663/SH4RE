//
//  ChatMessageModel.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-19.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
