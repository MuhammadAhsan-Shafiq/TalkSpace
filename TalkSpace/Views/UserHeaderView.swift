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
    var isTyping: Bool
    var isRecording: Bool
    var backAction: () -> Void // action to perform when back button is pressed
    var body: some View {
        HStack {
            // back Button
            Button(action: backAction ){
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
            }
            .padding(.trailing, 10)
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(radius: 5)
            VStack(alignment: .leading){
                Text(user.name)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(radius: 15)
                
                // conditional status for typing or recording
                if isTyping{
                    Text("Typing...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if isRecording{
                    Text("Recording...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            HStack(spacing: 10){
                Image(systemName: "phone.badge.plus")
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
            .font(.title2)
            .fontWeight(.bold)
        }
        .padding(.horizontal)
        
       // .shadow(radius: 10)
    }
}


// Preview for UserHeaderView
#Preview {
    UserHeaderView(user: User(name: "John Doe", email: "example@gmail.com"), isTyping: true, isRecording: false, backAction: { })
}
