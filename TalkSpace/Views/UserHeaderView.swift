//
//  UserHeaderView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import SwiftUI

// MARK: - User Header View
struct UserHeaderView: View {
    let user: User
    var body: some View {
        HStack {
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(radius: 5)
            
            Text(user.name)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .shadow(radius: 15)
            Spacer()
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


// Preview for UserHeaderView
#Preview {
    UserHeaderView(user: User(name: "John Doe", email: "example"))
}
