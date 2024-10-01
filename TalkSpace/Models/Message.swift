//
//  Message.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import FirebaseFirestore

struct Message: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var text: String?
    var imageUrl: String?
    var voiceNoteUrl: String?
    var senderId: String
    var timestamp: Timestamp
    var isCurrentUser: Bool = false // Not sent to Firestore, only used on client side

    // Default initializer without `isCurrentUser`
    init(id: String? = nil, text: String? = nil, imageUrl: String? = nil, voiceNoteUrl: String? = nil, senderId: String, timestamp: Timestamp = Timestamp(date: Date())) {
        self.id = id
        self.text = text
        self.imageUrl = imageUrl
        self.voiceNoteUrl = voiceNoteUrl
        self.senderId = senderId
        self.timestamp = timestamp
    }
}
