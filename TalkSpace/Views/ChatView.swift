import SwiftUI
import AVFAudio
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage



// MARK: - Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    let user: User
    let chatId: String
    @State private var message: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    
//    init(user: User, chatId: String) {
//        self.user = user
//        self.chatId = chatId
//    }
//    
    var body: some View {
        VStack(alignment: .leading) {
            UserHeaderView(user: user)
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message, viewModel: viewModel) // Pass the viewModel
                        }
                        Color.clear
                            .id("bottom")
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
                isRecording: $viewModel.isRecording,
                onRecordToggle: toggleRecording
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard() // Hide the keyboard when tapping outside
        }
        .onAppear {
            viewModel.loadMessages(chatId: chatId)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {presentationMode.wrappedValue.dismiss() }) {
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
        message = ""
        selectedImage = nil
    }
    
    // MARK: - Toggle Voice Recording
    private func toggleRecording() {
        if viewModel.isRecording {
            viewModel.stopRecording { voiceNoteUrl in
                if let url = voiceNoteUrl {
                    viewModel.sendMessage(voiceNoteUrl: url, chatId: chatId)
                }
            }
        } else {
            viewModel.startRecording()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


#Preview {
    ChatView(user: User(name: "Jane Doe", email: "example@gmail.com"), chatId: "chat123")
}
