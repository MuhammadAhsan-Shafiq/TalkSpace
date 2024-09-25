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
        VStack(alignment: .leading) {
                    // User header showing other user and their typing/recording status
                    UserHeaderView(user: otherUser, isTyping: viewModel.otherUserIsTyping, isRecording: viewModel.otherUserIsRecording)
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            VStack {
                                ForEach(viewModel.messages) { message in
                                    MessageBubbleView(message: message, viewModel: viewModel)
                                }
                                Color.clear.id("bottom")
                            }
                            .padding(.bottom, 10)
                            .onChange(of: viewModel.messages) { _ in
                                withAnimation {
                                    scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
            
            ChatInputView(
                           message: $message,
                           onSend: sendMessageAction,
                           showImagePicker: $showImagePicker,
                           isRecording: $isUserRecording,
                           onRecordToggle: toggleRecording,
                           onTypingChange: { isTyping in
                               isUserTyping = isTyping
                               viewModel.updateTypingStatus(isTyping: isTyping) // Sync typing status with Firestore
                           }
                       )
                   }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       hideKeyboard() // Hide the keyboard when tapping outside
                   }
                   .onAppear {
                       viewModel.loadMessages(chatId: chatId)
                       viewModel.listenForTypingAndRecording(userId: otherUser.id ?? "") // Listen for other user's status
                   }
                   .sheet(isPresented: $showImagePicker) {
                       ImagePicker(selectedImage: $selectedImage)
                           .onDisappear {
                               if let selectedImage = selectedImage {
                                   viewModel.uploadImage(image: selectedImage, chatId: chatId) // Upload selected image
                               }
                           }
                   }
                   .navigationBarBackButtonHidden()
                   .toolbar {
                       ToolbarItem(placement: .navigationBarLeading) {
                           Button(action: { presentationMode.wrappedValue.dismiss() }) {
                               Image(systemName: "chevron.left")
                                   .font(.headline)
                                   .foregroundColor(.blue)
                           }
                       }
                   }
               }
    
    // MARK: - Send Message Action
        private func sendMessageAction() {
            viewModel.sendMessage(text: message, chatId: chatId)
            message = "" // Reset the message field
            isUserTyping = false // Reset typing status
            viewModel.updateTypingStatus(isTyping: false) // Sync typing status with Firestore
        }
        
        // MARK: - Toggle Voice Recording
        private func toggleRecording() {
            if isUserRecording {
                viewModel.stopRecording { voiceNoteUrl in
                    if let url = voiceNoteUrl {
                        viewModel.sendMessage(voiceNoteUrl: url, chatId: chatId) // Send voice note message
                    }
                    isUserRecording = false
                    viewModel.updateRecordingStatus(isRecording: false) // Sync recording status with Firestore
                }
            } else {
                viewModel.startRecording()
                isUserRecording = true
                viewModel.updateRecordingStatus(isRecording: true) // Sync recording status with Firestore
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
