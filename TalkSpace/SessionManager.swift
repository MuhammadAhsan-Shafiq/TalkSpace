import SwiftUI
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = user != nil
        }
    }
    
    // Function to handle sign in
    func signInUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            self.isLoggedIn = true
            completion(nil)
        }
    }
    
    // Function to handle sign out
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
