//
//  ChatModel.swift
//  chatApp
//
//  Created by Infoicon on 17/04/24.
//

import Foundation
import FirebaseFirestore

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
