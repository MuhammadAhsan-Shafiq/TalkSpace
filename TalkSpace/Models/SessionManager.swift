import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle? // Store the listener handle

    init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = user != nil
        }
    }

    // Remove the listener when this object is deinitialized
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Function to handle sign in
    func signInUser(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                completion("Unable to retrieve user")
                return
            }
           
            // Fetch the user data after sign-in
            self.fetchUserData(uid: user.uid, completion: completion)
        }
    }
    
    // Function to handle sign out
    func signOutUser(completion: @escaping (String?) -> Void) {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            completion(nil) // Indicate success with no error message
        } catch {
            completion("Error signing out: \(error.localizedDescription)") // Pass error message
        }
    }
    
    // Function to sign up the user and save user data in Firestore
    func signUpUser(name: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                completion("Unable to retrieve user")
                return
            }
            
            let userData = [
                "name": name,
                "email": email,
                "uid": user.uid
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion("Error saving your data: \(error.localizedDescription)")
                } else {
                    completion(nil) // Success, no error
                }
            }
        }
    }

    // Fetch user data from Firestore
    func fetchUserData(uid: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                completion("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                completion(nil) // Success, no error
            } else {
                completion("User not found in Firestore")
            }
        }
    }
}
