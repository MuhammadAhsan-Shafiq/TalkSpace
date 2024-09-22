import SwiftUI
import AVFAudio
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage

// MARK: - Message Model
struct Message: Codable, Identifiable,Equatable {
    @DocumentID var id: String?
       var text: String?
       var imageUrl: String?
       var voiceNoteUrl: String?
       var isCurrentUser: Bool
       var senderId: String
       var timestamp: Timestamp
    
    // Custom initializer (if needed)
    init(id: String? = nil, text: String? = nil, imageUrl: String? = nil, voiceNoteUrl: String? = nil, isCurrentUser: Bool, senderId: String, timestamp: Timestamp = Timestamp(date: Date())) {
        self.id = id
        self.text = text
        self.imageUrl = imageUrl
        self.voiceNoteUrl = voiceNoteUrl
        self.isCurrentUser = isCurrentUser
        self.senderId = senderId
        self.timestamp = timestamp
    }
}

// MARK: - Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    let user: User
    let chatId: String
    @State private var message: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    
    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
    }
    
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
              


// MARK: - Chat Input View
struct ChatInputView: View {
    @Binding var message: String
    var onSend: () -> Void
    @Binding var showImagePicker: Bool
    @Binding var isRecording: Bool
    var onRecordToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { showImagePicker = true }) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .padding(.leading)
            
            TextField("Message...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight: 30)
                .padding(5)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            if isRecording {
                Button(action: onRecordToggle) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    onRecordToggle()
                }) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
            
            
            
            Button(action: {
                if !message.isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(message.isEmpty ? .gray : .blue)
                
            }
            .disabled(message.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Implement Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Hide Keyboard Function
extension View {
    
}

#Preview {
        ChatView(user: User(name: "Jane Doe", email: "example@gmail.com"), chatId: "chat123")
}
