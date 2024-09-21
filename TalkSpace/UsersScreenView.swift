import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseAuth

// User Model
struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let name: String
    let email: String
    
    // get the first letter of each word in the name and joins them up as initials
    var initials: String {
        let nameComponents = name.split(separator: " ").map { String($0.prefix(1)) }
        return nameComponents.joined()
    }
}

// struct to handle any sign in errors and display them
struct SignInError: Identifiable {
    var id: String { message } // Use the message itself as the unique identifier
    let message: String
}

// this is main screen to display users
// UsersScreenView
struct UsersScreenView: View {
    @State private var users: [User] = []
    @State private var isLoading: Bool = true
    @State private var signInError: SignInError? = nil
    @State private var currentUser: User? = nil // track the current signed-in user
    
    @Environment(\.dismiss) var dismiss // Environment to manage view dismissal
    
    private let db = Firestore.firestore()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if let currentUser = currentUser {
                    // Display the current user's name (Safely unwrapped)
                    Text(currentUser.name)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(radius: 15)
                } else {
                    Text("Loading User...")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(radius: 15)
                }
                
                if isLoading {
                    ProgressView("Loading....")
                } else {
                    List(users) { user in
                        if user.email != currentUser?.email { // Exclude the current user from the chat list
                            let chatId = getChatId(for: currentUser, with: user) // Generate chat ID
                            NavigationLink(destination: ChatView(user: user, chatId: chatId)) {
                                UserRowView(user: user)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationBarBackButtonHidden()
                    
                    // Logout button
                    Button(action: {
                        handleLogout() // Handle logout action
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .frame(width: 100, height: 35)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                fetchCurrentUser() // Fetch the current signed-in user
                fetchUsers()       // Fetch users from Firestore
            }
            .alert(item: $signInError) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Function to generate a unique chat ID based on the two user emails
    private func getChatId(for currentUser: User?, with otherUser: User) -> String {
        guard let currentUser = currentUser else {
            return "" // Return empty chatId if currentUser is nil
        }
        // Create a unique chat ID by joining sorted emails
        let ids = [currentUser.email, otherUser.email].sorted()
        return ids.joined(separator: "_")
    }
    
    // Fetch the current signed-in user
    private func fetchCurrentUser() {
        if let user = Auth.auth().currentUser {
            let userID = user.uid // Get the user ID
            let userRef = db.collection("users").document(userID) // Reference to the current user's Firestore document
            
            userRef.getDocument { document, error in
                if let error = error {
                    signInError = SignInError(message: error.localizedDescription)
                    return
                }
                
                // Try to decode the user data from Firestore
                if let document = document, document.exists, let fetchedUser = try? document.data(as: User.self) {
                    self.currentUser = fetchedUser // Assign the fetched user to the currentUser state
                } else {
                    signInError = SignInError(message: "User not found in Firestore")
                }
            }
        }
    }

    // Fetch all users from Firestore
    private func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                signInError = SignInError(message: error.localizedDescription)
                isLoading = false
                return
            }
            guard let documents = snapshot?.documents else {
                signInError = SignInError(message: "No User Found")
                isLoading = false
                return
            }
            
            users = documents.compactMap { document in
                try? document.data(as: User.self)
            }
            isLoading = false
        }
    }
    
    // Handle the logout functionality
    private func handleLogout() {
        do {
            try Auth.auth().signOut() // Sign out from Firebase
            
            // Navigate back to the login screen
            dismiss() // Dismiss the current screen to go back to the previous screen
        } catch {
            signInError = SignInError(message: error.localizedDescription)
        }
    }
}

// UserRowView
struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack { // Display initials in a circular shape
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
            }
        }
    }
}

#Preview {
    UsersScreenView()
}
