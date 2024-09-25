import SwiftUI
import FirebaseAuth
import FirebaseFirestore


class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("User is signed in: \(user.uid)")
            } else {
                print("No user is signed in.")
            }
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
            
            guard let user = authResult?.user else {
                completion("Unable to retrieve user")
                return
            }
           
            // fetch the userdata after sign-in
            self.fetchUserData(uid: user.uid, completion: completion)
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
            print("User Data to be saved: \(userData)") // Debugging line
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion("Error saving your data: \(error.localizedDescription)")
                    return
                } else {
                    print("User created with UID: \(user.uid)") // Add logging here
                    completion(nil)
                }
            }
        }
    }

    func fetchUserData(uid: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        print("Fetching user with UID: \(uid)") // Log the UID
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print("User Data: \(document.data() ?? [:])")
                completion(nil) // Success, no error
            } else {
                print("No such user found")
                completion("User not found in Firestore")
            }
        }
    }
}
