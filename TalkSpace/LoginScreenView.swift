import SwiftUI
import FirebaseAuth

// The main view for the login screen
struct LoginScreenView: View {
    
    @EnvironmentObject private var sessionManager: SessionManager // Use environment object for session management
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var signInError: String? = nil
    @State private var navigateToUsersScreen: Bool = false
    @State private var isLoggedIn: Bool = false // Track the login button click
    
    // MARK: - Validation Methods
    
    // Check if the email is valid
    private func isEmailValid() -> Bool {
        return Validator.isEmailValid(email)
    }
    
    // Check if the password meets all criteria
    private func isPasswordValid() -> Bool {
        return Validator.isPasswordValid(password)
    }
    
    // MARK: - Credential Handling
    
    // Save credentials when the "Remember Me" toggle is selected
    private func saveCredentials() {
        if rememberMe {
            UserDefaults.standard.set(email, forKey: "SavedEmail")
            UserDefaults.standard.set(password, forKey: "SavedPassword")
        } else {
            UserDefaults.standard.removeObject(forKey: "SavedEmail")
            UserDefaults.standard.removeObject(forKey: "SavedPassword")
        }
    }
    
    // Retrieve saved credentials when "Remember Me" is toggled
    private func retrieveCredentials() {
        if let savedEmail = UserDefaults.standard.string(forKey: "SavedEmail"),
           let savedPassword = UserDefaults.standard.string(forKey: "SavedPassword") {
            email = savedEmail
            password = savedPassword
        }
    }
    
    // MARK: - User Authentication
    
    // Sign in the user with email and password using sessionManager
    private func signInUser() {
        guard isFormValid() else { return }
        
        isLoggedIn = true // Show progress view inside the button
        
        sessionManager.signInUser(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                signInError = errorMessage
                isLoggedIn = false // Reset progress on error
                return
            }
            navigateToUsersScreen = true // Navigate on success
        }
    }
    
    // Check if the form is valid (email and password validation)
    private func isFormValid() -> Bool {
        return isEmailValid() && isPasswordValid()
    }
    
    // MARK: - Body View
    
    var body: some View {
        NavigationStack {
            if sessionManager.isLoggedIn {
                // If user is already logged in, navigate to UsersScreenView
                UsersScreenView()
                    .environmentObject(sessionManager) // Pass the session manager
            } else {
                ZStack {
                    VStack {
                        // Main title
                        headerView
                        
                        Spacer()
                        
                        // Login form
                        VStack(alignment: .leading, spacing: 15) {
                            loginForm
                            
                            // Error message if there is a sign-in error
                            if let signInError = signInError {
                                Text(signInError)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                            
                            // Remember me toggle and Forget password button
                            formOptions
                            
                            // Login and Sign-Up Navigation
                            loginActions
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(20)
                        .shadow(radius: 15)
                        
                        Spacer()
                        
                        // Navigation to sign-up screen
                        NavigationLink("Don't have an account? Sign Up", destination: SignUpScreenView())
                            .foregroundColor(.black)
                            .font(.footnote)
                    }
                    .padding()
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard() // Dismiss keyboard on tap
                    }
                }
            }
        }
        .onAppear {
            retrieveCredentials() // Auto-fill saved credentials
        }
    }
    
    // MARK: - Subviews
    
    // Header view containing the main title
    private var headerView: some View {
        Text("TalkSpace")
            .font(.system(size: 50, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .shadow(radius: 15)
    }
    
    // The login form including email and password fields and validation
    private var loginForm: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Login")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .shadow(radius: 15)
            VStack(alignment:.leading){
                // Email input field and validation
                CustomInputField(icon: "envelope.fill", placeholder: "Enter Your Email", text: $email, keyboardType: .emailAddress)
                ValidationRequirement(text: "Invalid Email Address", isValid: isEmailValid())
                
                // Password input field and validation requirements
                CustomInputField(
                    icon: "lock.fill",
                    placeholder: "Enter Your Password",
                    text: $password,
                    isSecure: true,
                    isPasswordVisible: isPasswordVisible,
                    toggleVisibility: { isPasswordVisible.toggle() }
                )
                passwordValidation
            }
        }
    }
    
    // Password validation requirements displayed below the password field
    private var passwordValidation: some View {
        Group {
            ValidationRequirement(text: "At least one uppercase letter", isValid: Validator.hasUpperCase(password))
            ValidationRequirement(text: "At least one lowercase letter", isValid: Validator.hasLowerCase(password))
            ValidationRequirement(text: "At least one digit", isValid: Validator.hasDigit(password))
            ValidationRequirement(text: "At least one special character", isValid: Validator.hasSpecialCharacter(password))
            ValidationRequirement(text: "At least 6 characters long", isValid: Validator.hasMinimumLength(password))
        }
    }
    
    // "Remember me" toggle and "Forget password" button
    private var formOptions: some View {
        HStack {
            Toggle(isOn: $rememberMe) {
                Text("Remember me")
                    .font(.system(size: 25))
                    .foregroundColor(.black)
            }
            .onChange(of: rememberMe) { _ in
                saveCredentials() // Save or remove credentials based on toggle
            }
            
            Spacer()
            
           
        }
        .padding(.horizontal)
    }
    
    // Login and navigation buttons
    private var loginActions: some View {
        HStack {
            Button("Forget Password") {
                // Handle forget password action
            }
            .font(.footnote)
            .foregroundColor(.black)
            .padding(8)
            
            loginButton
            
            // Navigation to UsersScreenView
            NavigationLink(destination: UsersScreenView(), isActive: $navigateToUsersScreen) {
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
    
    // Login button with progress view
    private var loginButton: some View {
        Button(action: signInUser) {
            if isLoggedIn {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 20, height: 20)
            } else {
                Text("Login")
                    .font(.system(size: 20))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(isFormValid() ? Color.white : Color.white.opacity(0.3))
                    .foregroundColor(isFormValid() ? .black : .gray)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .disabled(!isFormValid())
    }
}

// Custom input field used for both email and password inputs
struct CustomInputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isPasswordVisible: Bool? = nil
    var toggleVisibility: (() -> Void)? = nil
    var keyboardType: UIKeyboardType = .default
    var onEditingChanged: ((Bool) -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            // Display SecureField or TextField based on isSecure and password visibility
            if isSecure {
                if isPasswordVisible ?? false {
                    TextField(placeholder, text: $text, onEditingChanged: onEditingChanged ?? { _ in })
                } else {
                    SecureField(placeholder, text: $text)
                }
            } else {
                TextField(placeholder, text: $text, onEditingChanged: onEditingChanged ?? { _ in })
            }
        }
        .keyboardType(keyboardType)
        .autocapitalization(.none)
        .foregroundColor(.black)
        .frame(height: 25)
        .padding(5)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
        .overlay(
            HStack {
                Spacer()
                if let isPasswordVisible = isPasswordVisible {
                    Button(action: {
                        toggleVisibility?()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 8)
                }
            }
        )
    }
}

// Validation requirement view used for displaying the validation requirements
struct ValidationRequirement: View {
    var text: String
    var isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            Text(text)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .padding(.vertical, 2)
    }
}

// Validator for checking the password criteria
struct Validator {
    static func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Z|a-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        return hasUpperCase(password) &&
               hasLowerCase(password) &&
               hasDigit(password) &&
               hasSpecialCharacter(password) &&
               hasMinimumLength(password)
    }
    
    static func hasUpperCase(_ password: String) -> Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    static func hasLowerCase(_ password: String) -> Bool {
        return password.range(of: "[a-z]", options: .regularExpression) != nil
    }
    
    static func hasDigit(_ password: String) -> Bool {
        return password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    static func hasSpecialCharacter(_ password: String) -> Bool {
        return password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
    }
    
    static func hasMinimumLength(_ password: String) -> Bool {
        return password.count >= 6
    }
}

// Extension to dismiss the keyboard
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
