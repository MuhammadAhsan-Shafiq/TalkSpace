import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage

// MARK: - Message Model
struct Message: Identifiable, Equatable, Codable {
    let id: String
    let text: String
    let isSentByCurrentUser: Bool
    let timestamp: Timestamp
    let imageUrl: String? // Add image url for image messages
    
    // enum to define keys for decoding and encoding to Firestore
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case isSentByCurrentUser
        case timestamp
        case imageUrl
    }
    
    // Firestore requires an empty initializer for decoding
    init(id: String = UUID().uuidString, text: String, isSentByCurrentUser: Bool, timestamp: Timestamp = Timestamp(), imageUrl: String? = nil) {
        self.id = id
        self.text = text
        self.isSentByCurrentUser = isSentByCurrentUser
        self.timestamp = timestamp
        self.imageUrl = imageUrl
    }
}

// MARK: - Chat View
struct ChatView: View {
    let user: User
    let chatId: String // Unique chat id between the users
    @State private var message: String = ""
    @State private var messages: [Message] = []
    @State private var isCurrentUser: Bool = true // Track sender or receiver
    @State private var selectedImage: UIImage? // for image selection
    @State private var showImagePicker: Bool = false // to show image picker
    @Environment(\.presentationMode) var presentationMode
    @State private var listner: ListenerRegistration? // Firestore listner
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading) {
            // Step: 1 - User Header
            UserHeaderView(user: user)
            
            // Step: 2 - Message List
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                        }
                        Color.clear
                            .id("bottom")
                    }
                    .padding(.bottom, 10)
                    .onChange(of: messages) { _ in
                        withAnimation {
                            scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Step: 3 - Chat Input with image picker button
            ChatInputView(message: $message, onSend:  {
                if let selectedImage = selectedImage{
                    uploadImage(selectedImage) { result in
                        switch result {
                        case .success(let imageUrl):
                            sendMessage(imageUrl: imageUrl)
                        case .failure(let error):
                            print("print error uploading image: \(error.localizedDescription)")
                        }
                    }
                }else {
                    sendMessage()
                }
            }, showImagePicker: $showImagePicker)
        }
        .gesture(tapToDismissKeyboard)// apply geture to dismiss keyboard
        .onAppear{
            loadMessages()
        }
        .onDisappear{
            listner?.remove() // Remove the firestore listner when the view disappear
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showImagePicker){
            ImagePicker(selectedImage: $selectedImage)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.blue)
                })
            }
        }
    }
    
    //MARK: - Gesture to dismiss the keyboard
    var tapToDismissKeyboard: some Gesture {
        TapGesture().onEnded{
            hideKeyboard()
        }
    }
    
    //MARK: Load Message from Firestore
    private func loadMessages() {
        guard let currentUserId = getCurrentUserId() else { return }
        
        db.collection("users").document(currentUserId)
            .collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                print("Loaded \(documents.count) messages")
                messages = documents.compactMap { document in
                    try? document.data(as: Message.self)
                }
            }
    }
    
    // MARK: send message (text or image)
    private func sendMessage(imageUrl: String? = nil) {
        guard let currentUserId = getCurrentUserId(), !message.isEmpty || imageUrl != nil  else { return }
        
        let newMessage = Message(text: message, isSentByCurrentUser: isCurrentUser, imageUrl: imageUrl)
        
        // Save the message to Firestore
        let messageRef = db.collection("users").document(currentUserId)
            .collection("chats").document(chatId)
            .collection("messages").document(newMessage.id)
        
        do {
            try messageRef.setData(from: newMessage)
        } catch let error {
            print("Error saving message: \(error.localizedDescription)")
        }
        
        // Update last message timestamp in the chat document
        updateLastMessageTimestamp()
        
        // Clear the message field and switch sender
        message = ""
        selectedImage = nil
        isCurrentUser.toggle()
    }
    
    // MARK: Update chat TimeStamp
    private func updateLastMessageTimestamp() {
        guard let currentUserId = getCurrentUserId() else {
            print("No user is currently signed in")
            return
        }
        let chatRef = db.collection("users").document(currentUserId)
            .collection("chats").document(chatId)
        
        chatRef.updateData([
            "lastMessageTimestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating chat timestamp: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Get current user id
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
        
    }
    
    // MARK: upload image to firebase storage
    private func uploadImage(_ image: UIImage, completion: @escaping(Result<String, Error>)-> Void){
        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metaData){ metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL{url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
    // MARK: Hide Keyboard
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
    var body: some View {
        HStack {
            if message.isSentByCurrentUser {
                Spacer()
            }
            // Step: 10 - show image if available otherwise show text
            if let imageUrl = message.imageUrl, !imageUrl.isEmpty{
                AsyncImage(url: URL(string: imageUrl)){ image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width:150, height: 150)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text(message.text)
                    .padding()
                    .background(message.isSentByCurrentUser ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .font(.system(size: 18))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true) // Prevent text from truncating
            }
            if !message.isSentByCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: Chat Input View
struct ChatInputView: View {
    @Binding var message: String
    var onSend: () -> Void
    @Binding var showImagePicker: Bool
    var body: some View {
        HStack {
            Button(action: {
                showImagePicker = true // show the image picker
            }){
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .padding(.leading)
            
            // text field for message
            TextEditor(text: $message)
                .frame(height: 60) // Fixed height for TextEditor
                .border(Color.black.opacity(0.5))
                .font(.system(size: 20))
                .padding(5)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            Spacer()
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .padding(.trailing)
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
        }
        //.padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: implement image picker
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage{
                parent.selectedImage = originalImage
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ChatView(user: User(name: "Jane Doe", email: "example@gmail.com"), chatId: "chat123")
    
}
