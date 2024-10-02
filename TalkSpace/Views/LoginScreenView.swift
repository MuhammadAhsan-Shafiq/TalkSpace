import SwiftUI
import FirebaseAuth

// The main view for the login screen
struct LoginScreenView: View {
    
    @EnvironmentObject private var sessionManager: SessionManager // Use environment object for session management
    @ObservedObject private var viewModel: AuthViewModel // StateObject for AuthViewModel
    @Environment(\.colorScheme) var colorScheme // get the current color scheme
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
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
                    // background color based on current color scheme
                    colorScheme == .dark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                    VStack {
                        // Main title
                        headerView
                        Spacer()
                        loginForm
                        Spacer()
                        signUpLink
                    }
                    .padding()
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
                    .onAppear {
                        viewModel.retrieveCredentials()
                    }
                }
            }
        }
    }
    
    // Header view for the app's title
    private var headerView: some View {
        Text("TalkSpace")
            .font(.system(size: 50, weight: .bold, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .white : .black )
            .shadow(radius: 15)
    }
    
    // The login form including email and password fields and validation
    private var loginForm: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Login")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .shadow(radius: 15)
            
            VStack(alignment: .leading){
                // Email input field and validation
                CustomInputField(icon: "envelope.fill", placeholder: "Enter Your Email", text: $viewModel.email, keyboardType: .emailAddress)
                ValidationRequirement(text: "Invalid Email Address", isValid: viewModel.isEmailValid)
                
                // Password input field and validation requirements
                CustomInputField(
                    icon: "lock.fill",
                    placeholder: "Enter Your Password",
                    text: $viewModel.password,
                    isSecure: !viewModel.isPasswordVisible, // Control the secure field based on the password visibility
                    isPasswordVisible: viewModel.isPasswordVisible,
                    toggleVisibility: { viewModel.togglePasswordVisibility() } // Toggle password visibility from viewModel
                )
                passwordValidation
            }
            
            // Display login error if any
            if let errorMessage = viewModel.signInError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            formOptions
            loginActions
        }
        .padding()
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.black.opacity(0.1)) // Form background color
        .cornerRadius(20)
        .shadow(radius: 15)
    }
    
    // Password validation requirements displayed below the password field
        private var passwordValidation: some View {
            Group {
                ValidationRequirement(text: "At least one uppercase letter", isValid: viewModel.hasUppercase)
                ValidationRequirement(text: "At least one lowercase letter", isValid: viewModel.hasLowercase)
                ValidationRequirement(text: "At least one digit", isValid: viewModel.hasDigit)
                ValidationRequirement(text: "At least one special character", isValid: viewModel.hasSpecialCharacter)
                ValidationRequirement(text: "At least 6 characters long", isValid: viewModel.hasMinimumLength)
            }
        }
    
    // "Remember me" toggle and "Forget password" button
    private var formOptions: some View {
        HStack {
            Toggle(isOn: $viewModel.rememberMe) {
                Text("Remember me")
                    .font(.system(size: 25))
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Toggle text color
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
            .foregroundColor(colorScheme == .dark ? .white : .black) // Forget password button text color
            .padding(8)
            
            Button(action: { viewModel.signInUser() }) {
                if viewModel.isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                } else {
                    Text("Login")
                        .font(.system(size: 20))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLoginFormValid ? Color.white : Color.white.opacity(0.3))
                        .foregroundColor(viewModel.isLoginFormValid ? .black : .gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .disabled(!viewModel.isLoginFormValid)
        }
        .padding(.horizontal)
    }
    
    // Link to the SignUpScreenView
    private var signUpLink: some View {
        NavigationLink("Don't have an account? Sign Up", destination: SignUpScreenView(viewModel: viewModel))
            .foregroundColor(colorScheme == .dark ? .white : .black) // Sign up link color
            .font(.footnote)
    }
}
