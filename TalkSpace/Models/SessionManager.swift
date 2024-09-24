import SwiftUI
import FirebaseAuth
import FirebaseFirestore


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
    
    // Sign Up the user and save user data in firestore
    func signUpUser(name:String, email: String, password: String, completion: @escaping (String?) -> Void) {
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
                    return
                } else {
                    completion(nil)
                }
            }
        }
    }
}
