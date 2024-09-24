//
//  UserViewModel.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = true
    @Published var currentUser: User?
    @Published var signInError: String?
    
    private let db = Firestore.firestore()
    
    init() {
        fetchUsers() //Fetch the list of user from firestore
        fetchCurrentUser() //  fetch the current the when the view model is initialized
    }
    
    // Fetch the current signed-in user
    private func fetchCurrentUser() {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { document, error in
                if let error = error {
                    self.signInError = error.localizedDescription
                    return
                }
                
                if let document = document, document.exists, let fetchedUser = try? document.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.currentUser = fetchedUser
                    }
                } else {
                    self.signInError = "User not found in Firestore"
                }
            }
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
                self.users = documents.compactMap { document in
                    try? document.data(as: User.self)
                }
                self.isLoading = false
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
