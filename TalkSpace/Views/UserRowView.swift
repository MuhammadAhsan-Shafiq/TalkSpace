//
//  UserRowView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import SwiftUI

// UserRowView
struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack { // Display initials in a circular shape
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
            }
        }
    }
}
#Preview {
    UserRowView(user: User(id: "", name: "hello world", email: ""))
}
