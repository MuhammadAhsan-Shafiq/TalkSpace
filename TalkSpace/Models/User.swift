//
//  User.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import Foundation
import FirebaseFirestore

// User Model
struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let name: String
    let email: String
    var isTyping: Bool? = false
    var isRecording: Bool? = false
    
    // get the first letter of each word in the name and joins them up as initials
    var initials: String {
        let nameComponents = name.split(separator: " ").map { String($0.prefix(1)) }
        return nameComponents.joined()
    }
}

