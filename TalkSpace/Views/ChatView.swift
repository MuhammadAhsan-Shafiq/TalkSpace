import SwiftUI
import AVFAudio
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage

// MARK: - Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    let user: User // Current User
    let otherUser: User // Other user in the chat
    let chatId: String
    
    @State private var message: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var isUserTyping: Bool = false
    @State private var isUserRecording: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background color
                       Color.yellow.opacity(0.1)
                           .ignoresSafeArea() // Extend the color to the edges
            VStack(alignment: .leading) {
                UserHeaderView(user: otherUser,
                               isTyping: viewModel.otherUserIsTyping,
                               isRecording: viewModel.otherUserIsRecording,
                               backAction: { presentationMode.wrappedValue.dismiss() })
                .padding(.vertical,5)
                .background(Color.white)
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message, viewModel: viewModel)
                            }
                            Color.clear.id("bottom")
                            //   .background(Color.yellow.opacity(0.1))
                        }
                        
                        .padding(.bottom, 10)
                        .onChange(of: viewModel.messages) { _ in
                            withAnimation {
                                scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                   // .background(Color.yellow.opacity(0.1))
                }
                
                ChatInputView(
                    message: $message,
                    onSend: sendMessageAction,
                    showImagePicker: $showImagePicker,
                    isRecording: $isUserRecording,
                    onRecordToggle: toggleRecording,
                    onTypingChange: { isTyping in
                        isUserTyping = isTyping
                        viewModel.updateTypingStatus(isTyping: isTyping)
                    }
                )
               
            }
            
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                viewModel.loadMessages(chatId: chatId)
                viewModel.listenForTypingAndRecording(userId: otherUser.id ?? "")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if let selectedImage = selectedImage {
                            viewModel.uploadImage(image: selectedImage, chatId: chatId)
                        }
                    }
            }
            .navigationBarBackButtonHidden()
        }
    }

    // MARK: - Send Message Action
    private func sendMessageAction() {
        viewModel.sendMessage(text: message, chatId: chatId)
        message = ""
        isUserTyping = false
        viewModel.updateTypingStatus(isTyping: false)
    }

    // MARK: - Toggle Voice Recording
    private func toggleRecording() {
        if isUserRecording {
            viewModel.stopRecording { voiceNoteUrl in
                if let url = voiceNoteUrl {
                    viewModel.sendMessage(voiceNoteUrl: url, chatId: chatId)
                }
                isUserRecording = false
                viewModel.updateRecordingStatus(isRecording: false)
            }
        } else {
            viewModel.startRecording()
            isUserRecording = true
            viewModel.updateRecordingStatus(isRecording: true)
        }
    }

    // MARK: - Hide Keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ChatView(
        user: User(name: "Jane Doe", email: "example@gmail.com"),
        otherUser: User(name: "John Doe", email: "john@gmail.com"),
        chatId: "chat123"
    )
}
