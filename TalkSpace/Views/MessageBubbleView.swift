//
//  MessageBubbleView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import SwiftUI
import FirebaseCore

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
        @ObservedObject var viewModel: ChatViewModel // Add this line
    
    var body: some View {
        HStack {
                    if message.isCurrentUser {
                        Spacer()
                        bubbleContent
                            .onTapGesture {
                                // Tap to play voice note if available
                                if let voiceNoteUrl = message.voiceNoteUrl {
                                    viewModel.playVoiceNote(url: voiceNoteUrl)
                                }
                            }
                    } else {
                        bubbleContent
                            .onTapGesture {
                                // Tap to play voice note if available
                                if let voiceNoteUrl = message.voiceNoteUrl {
                                    viewModel.playVoiceNote(url: voiceNoteUrl)
                                }
                            }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
                .padding(.horizontal)
            }
    @ViewBuilder
    private var bubbleContent: some View{
        if let text = message.text {
            Text(text)
                .padding()
                .background(message.isCurrentUser ? Color.blue : Color.gray) // Sent message color
                .foregroundColor(.white)
                .cornerRadius(15)
              //  .padding(.leading, 50)
                .padding(.trailing, 10) // Adjust right padding for sent messages
                .padding(.vertical, 5)
        } else if let imageUrl = message.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 5)
            } placeholder: {
                ProgressView()
            }
        } else if let voiceNoteUrl = message.voiceNoteUrl {
            Button(action: {
                viewModel.playVoiceNote(url: voiceNoteUrl)
            }){
                HStack{
                    Image(systemName: "waveform")
                    Text("Voice Note")
                }
                .padding()
                .background(message.isCurrentUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.vertical, 5)
            }
        }
    }
}
  

// Preview for MessageBubbleView
#Preview {
    let message = Message(text: "Hello, world!", isCurrentUser: true, senderId: "userId", timestamp: Timestamp(date: Date()))
    MessageBubbleView(message: message, viewModel: ChatViewModel())
}
