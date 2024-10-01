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
    @Published var audioLevel: Float = 0.0
    @Published var isTyping: Bool = false
    @Published var otherUserIsTyping: Bool = false
    @Published var otherUserIsRecording: Bool = false
    @Published var currentVoiceNoteUrl: String? = nil
    @Published var isPlayingVoiceNote: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var typingListener: ListenerRegistration?
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioLevelTimer: Timer?

    
    // MARK: Load messages from Firestore
    func loadMessages(chatId: String) {
        listener?.remove()

        // Determine the current user ID before setting the listener
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error Fetching Messages: \(error)")
                    return
                }

                // Map each document to a Message object and set `isCurrentUser` based on senderId
                self.messages = querySnapshot?.documents.compactMap { document in
                    if var message = try? document.data(as: Message.self) {
                        // Copy the message object and modify `isCurrentUser` in the copy
                        message.isCurrentUser = message.senderId == currentUserId
                        return message
                    }
                    return nil
                } ?? []
            }
    }
    
    // MARK: Send Message Function
    func sendMessage(text: String? = nil, imageUrl: String? = nil, voiceNoteUrl: String? = nil, chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Set isCurrentUser to true since this function sends messages from the current user
        let message = Message(
            text: text,
            imageUrl: imageUrl,
            voiceNoteUrl: voiceNoteUrl,
            senderId: currentUserId,
            timestamp: Timestamp(date: Date())
        )

        do {
            // Attempt to add the document
            try db.collection("chats").document(chatId).collection("messages").addDocument(from: message) { error in
                if let error = error {
                    print("Error saving message: \(error.localizedDescription)")
                } else {
                    print("Message successfully sent!")
                }
            }
        } catch {
            print("Failed to send message: \(error.localizedDescription)")
        }
    }


    // MARK: Upload image function
    func uploadImage(image: UIImage, chatId: String) {
        let storageRef = Storage.storage().reference().child("chat_images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                print("Error uploading image: \(String(describing: error))")
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
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            updateRecordingStatus(isRecording: true) // Update recording status in Firestore
            
            // start monitoring audio levels
            audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1,repeats: true){ [weak self] _ in
                self?.audioRecorder?.updateMeters()
                self?.audioLevel = self?.audioRecorder?.averagePower(forChannel: 0) ?? 0
            }
            updateRecordingStatus(isRecording: true)
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    // MARK: Stop voice recording
    func stopRecording(completion: @escaping (String?) -> Void) {
        audioRecorder?.stop()
        isRecording = false
        audioLevelTimer?.invalidate() // Stop the audio level timer
        
        guard let url = audioRecorder?.url else { return completion(nil) }
        uploadVoiceNote(url: url, completion: completion)
        updateRecordingStatus(isRecording: false) // Update recording status in Firestore
    }
    
    // MARK: Update Typing Status Function
    func updateTypingStatus(isTyping: Bool) {
        self.isTyping = isTyping
        guard let currentUserId = getCurrentUserId() else { return }
        
        // Update Firestore with typing status for the current user
        db.collection("users").document(currentUserId).updateData(["isTyping": isTyping]) { error in
            if let error = error {
                print("Error updating typing status: \(error)")
            }
        }
    }
    
    // MARK: Update Recording Status Function
    func updateRecordingStatus(isRecording: Bool) {
        self.isRecording = isRecording
        if let currentUserId = getCurrentUserId() {
            db.collection("users").document(currentUserId).updateData(["isRecording": isRecording]) { error in
                if let error = error {
                    print("Error updating recording status: \(error)")
                }
            }
        }
    }
    
    // MARK: Listen for typing and recording status of other users
    func listenForTypingAndRecording(userId: String) {
        typingListener?.remove()
        typingListener = db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let data = documentSnapshot?.data() else { return }
            self?.otherUserIsTyping = data["isTyping"] as? Bool ?? false
            self?.otherUserIsRecording = data["isRecording"] as? Bool ?? false
        }
    }
    
    
    // MARK: Upload Voice Note
    func uploadVoiceNote(url: URL, completion: @escaping (String?) -> Void) {
        guard getCurrentUserId() != nil else { return }
        
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
    
    func playVoiceNote(url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL: \(url)")
            return
        }

        do {
            print("Playing audio from: \(url)") // Log the URL
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing voice note: \(error.localizedDescription)")
        }
    }
}
