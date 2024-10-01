import SwiftUI
import FirebaseCore

struct MessageBubbleView: View {
    let message: Message
    @ObservedObject var viewModel: ChatViewModel // ObservedObject for ChatViewModel
    @State private var isImageFullScreen: Bool = false
    @Namespace private var imageNamespace

    var body: some View {
        ZStack {
            HStack {
                if message.isCurrentUser {
                    Spacer()
                    bubbleContent
                        .background(
                            SpeechBubbleShape(isCurrentUser: true)
                                .fill(Color.green)
                        )
                        .onTapGesture {
                            if let voiceNoteUrl = message.voiceNoteUrl {
                                viewModel.playVoiceNote(url: voiceNoteUrl)
                            }
                        }
                        .padding(.trailing, 15)
                } else {
                    bubbleContent
                        .background(
                            SpeechBubbleShape(isCurrentUser: false)
                                .fill(Color.white)
                        )
                        .onTapGesture {
                            if let voiceNoteUrl = message.voiceNoteUrl {
                                viewModel.playVoiceNote(url: voiceNoteUrl)
                            }
                        }
                        .padding(.leading, 15)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
            .padding(.horizontal)

            if isImageFullScreen, let imageUrl = message.imageUrl {
                FullScreenImageView(imageUrl: imageUrl, isFullScreen: $isImageFullScreen, namespace: imageNamespace)
            }
        }
    }
    
    @ViewBuilder
    private var bubbleContent: some View {
        if let text = message.text {
            Text(text)
                .padding(3)
                .foregroundColor(.black)
                //.background(Color.white.opacity(0.8))
//                .cornerRadius(15)
                .padding(10)
                //.padding(.vertical, 5)
        } else if let imageUrl = message.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 200)
                    .padding(.all, 5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isImageFullScreen = true
                        }
                    }
                    .matchedGeometryEffect(id: "chatImage", in: imageNamespace)
            } placeholder: {
                ProgressView()
            }
        } else if let voiceNoteUrl = message.voiceNoteUrl {
            VStack {
                HStack {
                    Button(action: {
                        viewModel.playVoiceNote(url: voiceNoteUrl)
                    }) {
                        Image(systemName: viewModel.isPlayingVoiceNote && viewModel.currentVoiceNoteUrl == voiceNoteUrl ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(message.isCurrentUser ? .white : .green)
                    }
                    if viewModel.isPlayingVoiceNote && viewModel.currentVoiceNoteUrl == voiceNoteUrl {
                        AudioVisualizerView(audioLevel: $viewModel.audioLevel)
                            .frame(width: 100, height: 40)
                            .padding(.horizontal, 5)
                    }
                }
                .padding()
                .background(message.isCurrentUser ? Color.green : Color.white)
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

