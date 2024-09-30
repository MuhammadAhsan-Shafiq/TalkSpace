//
//  MessageBubbleView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import SwiftUI
import FirebaseCore

// MARK: Custom speech bubble shape
struct SpeechBubbleShape: Shape {
    var isCurrentUser: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = 20
        
        if isCurrentUser {
            //   Start at the top-left corner, leaving space for rounded effect
            path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
            
            // Top-left rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + 20), control: CGPoint(x: rect.minX, y: rect.minY))
            
            // Left side
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 20))
            
            // Bottom-left rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.maxY), control: CGPoint(x: rect.minX, y: rect.maxY))
            
            // Bottom side (stopping before the tail)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Stop just before the tail
            
            // Sharp bottom-right corner with a straight line
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20)) // Move upwards sharply for a sharp corner
            
            // Tail pointing slightly outward
            path.addLine(to: CGPoint(x: rect.maxX + 15, y: rect.maxY - 10)) // Create a small tail pointing outward
            
            // Bring tail back to the bubble
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 40)) // Move upwards to rejoin the bubble
            
            // Right side
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 20))
            
            // Top-right rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.minY), control: CGPoint(x: rect.maxX, y: rect.minY))
            
            // Top side
            path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.minY))
        } else {
            // Start at the top-right corner, leaving space for rounded effect
            path.move(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
            
            // Top-right rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 20), control: CGPoint(x: rect.maxX, y: rect.minY))
            
            // Right side
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
            
            // Bottom-right rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            
            // Bottom side (stopping before the tail)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Stop just before the tail
            
            // Sharp bottom-left corner with a straight line
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 20)) // Move upwards sharply for a sharp corner
            
            // Tail pointing slightly outward on the left
            path.addLine(to: CGPoint(x: rect.minX - 15, y: rect.maxY - 10)) // Create a small tail pointing outward
            
            // Bring tail back to the bubble
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 40)) // Move upwards to rejoin the bubble
            
            // Left side
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 20))
            
            // Top-left rounded corner
            path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
            
            // Top side
            path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
        }
        
        return path
    }
}


// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    @ObservedObject var viewModel: ChatViewModel // Add this line
    @State private var isImageFullScreen: Bool = false
    @Namespace private var isImageNamespace
    
    var body: some View {
        ZStack{
        HStack {
            if message.isCurrentUser {
                Spacer()
                // show tail for recieved messages on the left
                bubbleContent
                    .background(
                        SpeechBubbleShape(isCurrentUser: true)
                            .fill(Color.green) // Use .fill directly on the Shape
                    )
                    .onTapGesture {
                        // Tap to play voice note if available
                        if let voiceNoteUrl = message.voiceNoteUrl {
                            viewModel.playVoiceNote(url: voiceNoteUrl)
                        }
                    }
                    .padding(.trailing, 15)
            } else {
                // show tail for sent messages on the right
                bubbleContent
                    .background(
                        SpeechBubbleShape(isCurrentUser: false)
                            .fill(Color.white) // Use .fill directly on the Shape
                    )
                    .onTapGesture {
                        // Tap to play voice note if available
                        if let voiceNoteUrl = message.voiceNoteUrl {
                            viewModel.playVoiceNote(url: voiceNoteUrl)
                        }
                    }
                    .padding(.leading,15)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
        .padding(.horizontal)
        
            // Full screen image View with matched geometry effect
            if isImageFullScreen, let imageUrl =  message.imageUrl {
                FullScreenImageView(imageUrl: imageUrl, isFullScreen: $isImageFullScreen, namespace: isImageNamespace)
            }
        }
    }
    
    @ViewBuilder
    private var bubbleContent: some View{
        if let text = message.text {
            Text(text)
                .padding(10)
                .foregroundColor(.black)
                .cornerRadius(15)
                .padding(.trailing, 10)
                .padding(.vertical, 5)
        } else if let imageUrl = message.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 200)
                    .padding(.all, 5)
                    .onTapGesture {
                        withAnimation(.spring()){
                            isImageFullScreen = true
                        }
                    }
                    .matchedGeometryEffect(id: "chatImage", in: imageNamespace)
            }
                placeholder: {
                ProgressView()
            }
        } else if let voiceNoteUrl = message.voiceNoteUrl {
            Button(action: {
                viewModel.playVoiceNote(url: voiceNoteUrl)
            }) {
                HStack {
                    Image(systemName: "waveform")
                    Text("Voice Note")
                }
                .padding()
                .background(message.isCurrentUser ? Color.green : Color.white)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.vertical, 5)
            }
        }
    }
}

// MARK: - Preview for MessageBubbleView
#Preview {
    let sampleMessage = Message(
        text: "Hello, world!",
        isCurrentUser: true,
        senderId: "userId",
        timestamp: Timestamp(date: Date())
    )
    MessageBubbleView(message: sampleMessage, viewModel: ChatViewModel())
}


struct FullScreenImageView: View {
    let imageUrl: String
    @Binding var isFullScreen: Bool
    var namespace: Namespace.ID // Recieved the shared namespace
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: imageUrl)){ image in
                image
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "chatImage", in: namespace) // apply the matched geometry effect
                    .onTapGesture {
                        withAnimation(.spring()){
                            isFullScreen = false
                        }
                    }
            } placeholder: {
                ProgressView()
            }
            
            Button(action: {
                withAnimation(.spring()){
                    isFullScreen = false
                }
            }){
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 30))
                    .padding()
            }
        }
    }
}

