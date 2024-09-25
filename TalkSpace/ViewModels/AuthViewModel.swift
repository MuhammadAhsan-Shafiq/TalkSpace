//
//  AuthViewModel.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
class AuthViewModel: ObservableObject {
    // shared properties for both sign-up and login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var isPasswordVisible: Bool = false
    
    // signupspecific properties
    @Published var name: String = ""
    @Published var signUpError: String? = nil
    @Published var isSignUp: Bool = false // track the sign up state
    
    // Login speacific properties
    @Published var signInError: String? = nil
    @Published var isLoggedIn: Bool = false
    
    // combine view states
    @Published var isAuthenticating: Bool = false
    @Published var authError: String? = nil
    
    private var sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        retrieveCredentials()
    }
    
    //MARK: Validation Logic
    var  isEmailValid: Bool {
        Validator.isEmailValid(email)
    }
    
    var isPasswordValid: Bool {
        Validator.isPasswordValid(password)
    }
    
    var hasUppercase: Bool {
        Validator.hasUpperCase(password)
    }
    
    var hasLowercase: Bool {
        Validator.hasLowerCase(password)
    }
    
    var hasDigit: Bool {
        Validator.hasDigit(password)
    }
    
    var hasSpecialCharacter: Bool {
        Validator.hasSpecialCharacter(password)
    }
    
    var hasMinimumLength: Bool {
        Validator.hasMinimumLength(password)
    }
    
    var isFormValid: Bool {
        isEmailValid && isPasswordValid && !name.isEmpty
    }
    
    var isLoginFormValid: Bool {
        isEmailValid && isPasswordValid
    }
    
    // MARK: SignUp the user and save user data in firestore
    func signUpUser() {
        guard isFormValid else {
            signUpError = "Please provide a valid email and password and name"
            return
        }
        
        isAuthenticating = true
        sessionManager.signUpUser(name: name, email: email, password: password) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.signUpError = error
            } else {
                self.signInError = nil
                self.signInUser() // Optionally sign in the user right after sign up
            }
            self.isAuthenticating = false
        }
    }

    
    
    // MARK: Sign-In Logic
    func signInUser() {
        guard isLoginFormValid else {
            signInError = "Please provide a valid email and password"
            return
        }
        
        isAuthenticating = true
        sessionManager.signInUser(email: email, password: password) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.signInError = error
            } else {
                self.signInError = nil
                self.isLoggedIn = true
                self.saveCredentials()
            }
            self.isAuthenticating = false
        }
    }
    // MARK: password visibility toggle
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
    
    // MARK: - Remember Me Logic
    private func saveCredentials() {
        if rememberMe {
            UserDefaults.standard.set(email, forKey: "SavedEmail")
            UserDefaults.standard.set(password, forKey: "SavedPassword")
        } else {
            UserDefaults.standard.removeObject(forKey: "SavedEmail")
            UserDefaults.standard.removeObject(forKey: "SavedPassword")
        }
    }
    
    // Retrieve saved credentials
    func retrieveCredentials() {
        if let savedEmail = UserDefaults.standard.string(forKey: "SavedEmail"),
           let savedPassword = UserDefaults.standard.string(forKey: "SavedPassword") {
            email = savedEmail
            password = savedPassword
            rememberMe = true
        }
    }
}
