import Combine
import FirebaseFirestore
import FirebaseAuth

class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = true
    @Published var currentUser: User?
    @Published var signInError: String?

    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchUsers()
        fetchCurrentUser()
        listenForUserStatusChanges()
        // Removed last message listening
    }
    
    // Fetch the current signed-in user
    private func fetchCurrentUser() {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            print("Fetching user with UID: \(userID)") // Debugging line
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.signInError = error.localizedDescription
                    return
                }
                
                // Check if the document exists
                if let document = document, document.exists, let fetchedUser = try? document.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.currentUser = fetchedUser
                    }
                } else {
                    self.signInError = "User not found in Firestore"
                }
            }
        } else {
            self.signInError = "User not authenticated"
        }
    }

    // Fetch all users from Firestore
    private func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.signInError = error.localizedDescription
                    self.isLoading = false
                }
                return
            }

            guard let documents = snapshot?.documents else {
                DispatchQueue.main.async {
                    self.signInError = "No Users Found"
                    self.isLoading = false
                }
                return
            }

            DispatchQueue.main.async {
                self.users = documents.compactMap { try? $0.data(as: User.self) }
                print("Fetched users: \(self.users.map { $0.name })") // Debugging: Check fetched user names
                self.isLoading = false
            }
        }
    }
    
    // Listen for real time updates on user typing and recording status
    private func listenForUserStatusChanges() {
        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for user status changes: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                if let user = try? document.data(as: User.self) {
                    // find the index of user and update their typing/ recording status
                    if let index = self.users.firstIndex(where: { $0.id == user.id }) {
                        self.users[index] = user
                    } else {
                        self.users.append(user) // Add user if not already in the list
                    }
                }
            }
        }
    }

    // handle the logout functionality
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            DispatchQueue.main.async {
                self.signInError = error.localizedDescription
            }
        }
    }

    // Generate unique chat ID based on emails
    func getChatId(with otherUser: User) -> String {
        guard let currentUser = currentUser else {
            return "" // Return empty chatId if currentUser is nil
        }
        let ids = [currentUser.email, otherUser.email].sorted()
        return ids.joined(separator: "_")
    }
}
