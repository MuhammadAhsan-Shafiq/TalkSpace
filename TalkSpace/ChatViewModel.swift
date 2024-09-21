import AVFAudio
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isRecording: Bool = false
    private var cancellables = Set<AnyCancellable>()

    private var db = Firestore.firestore()
    private var listner: ListenerRegistration?
    private var audioRecorder: AVAudioRecorder?
    
    // MARK: Load messages from Firestore
    func loadMessages(chatId: String) {
        // stop any existing listener
        listner?.remove()
        
        // listen for real-time updates
        listner = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp") // Ensure messages are ordered by timestamp
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No message")
                    return
                }
                
                // Map Firestore documents to Message objects and dynamically set isCurrentUser
                self?.messages = documents.compactMap { doc -> Message? in
                    guard var message = try? doc.data(as: Message.self) else { return nil }
                    
                    // Create a local copy and modify it
                    message.isCurrentUser = message.senderId == self?.getCurrentUserId()
                    
                    return message
                }

            }
    }
    
    // MARK: Function for sending message
    func sendMessage(text: String? = nil, imageUrl: String? = nil, voiceNoteUrl: String? = nil, chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let message = Message(
            text: text,
            imageUrl: imageUrl,
            voiceNoteUrl: voiceNoteUrl,
            isCurrentUser: true,  // Always true when sending a message from the current user
            senderId: currentUserId,
            timestamp: Timestamp(date: Date())
        )
        
        do {
            _ = try db.collection("chats").document(chatId).collection("messages").addDocument(from: message)
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    // MARK: Upload image function
    func uploadImage(image: UIImage, chatId: String) {
        let storageRef = Storage.storage().reference().child("chat_images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            guard error == nil else { String(describing: error)
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString, error == nil else { return }
                self?.sendMessage(imageUrl: imageUrl, chatId: chatId)
            }
        }
    }
    
    // MARK: Start voice recording
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    // MARK: Stop voice recording
    func stopRecording(completion: @escaping (String?) -> Void) {
        audioRecorder?.stop()
        isRecording = false
        
        guard let url = audioRecorder?.url else { return completion(nil) }
        uploadVoiceNote(url: url, completion: completion)
    }
    
    // MARK: Upload voice note
    func uploadVoiceNote(url: URL, completion: @escaping (String?) -> Void) {
        guard let currentUserId = getCurrentUserId() else { return }
        
        let storageRef = Storage.storage().reference().child("voice_notes/\(UUID().uuidString).m4a")
        
        storageRef.putFile(from: url, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload voice note: \(String(describing: error))")
                return completion(nil)
            }
            
            storageRef.downloadURL { url, error in
                guard let voiceNoteUrl = url?.absoluteString, error == nil else { return completion(nil) }
                completion(voiceNoteUrl)
            }
        }
    }
    
    // MARK: Get current user ID
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: Utility to get the document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
