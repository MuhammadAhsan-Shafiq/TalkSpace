//
//  Message.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import FirebaseFirestore

// MARK: - Message Model
struct Message: Codable, Identifiable,Equatable {
    @DocumentID var id: String?
       var text: String?
       var imageUrl: String?
       var voiceNoteUrl: String?
       var isCurrentUser: Bool
       var senderId: String
       var timestamp: Timestamp
    
    // Custom initializer (if needed)
    init(id: String? = nil, text: String? = nil, imageUrl: String? = nil, voiceNoteUrl: String? = nil, isCurrentUser: Bool, senderId: String, timestamp: Timestamp = Timestamp(date: Date())) {
        self.id = id
        self.text = text
        self.imageUrl = imageUrl
        self.voiceNoteUrl = voiceNoteUrl
        self.isCurrentUser = isCurrentUser
        self.senderId = senderId
        self.timestamp = Timestamp(date: Date())
    }
}
