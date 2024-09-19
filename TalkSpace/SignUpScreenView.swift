import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpScreenView: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var signUpError: String? = nil
    @State private var isSignUp: Bool = false // track the sign up state
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var sessionManager: SessionManager // Managing user sessions
    
    private func isEmailValid() -> Bool {
        return Validator.isEmailValid(email)
    }

    private func isPasswordValid() -> Bool {
        return Validator.isPasswordValid(password)
    }

    private func hasUppercase() -> Bool {
        return Validator.hasUpperCase(password)
    }

    private func hasLowercase() -> Bool {
        return Validator.hasLowerCase(password)
    }

    private func hasDigit() -> Bool {
        return Validator.hasDigit(password)
    }

    private func hasSpecialCharacter() -> Bool {
        return Validator.hasSpecialCharacter(password)
    }

    private func hasMinimumLength() -> Bool {
        return Validator.hasMinimumLength(password)
    }

    private func isFormValid() -> Bool {
        return isEmailValid() && isPasswordValid() && !name.isEmpty
    }

    private func signUpUser() {
        guard isFormValid() else {
            signUpError = "Please provide a valid email and password"
            return
        }
        
        isSignUp = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                signUpError = error.localizedDescription
                isSignUp = false
                return
            }

            guard let user = authResult?.user else {
                signUpError = "Unable to retrieve user"
                isSignUp = false
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
                    signUpError = "Error saving your data: \(error.localizedDescription)"
                    isSignUp = false
                } else {
                    signUpError = nil
                    sessionManager.signInUser(email: email, password: password) { error in
                        if let error = error {
                            signUpError = error
                            isSignUp = false
                        } else {
                            isSignUp = false
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("TalkSpace")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(radius: 15)
                    Spacer()
                    VStack {
                        Text("Sign Up")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .shadow(radius: 15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            CustomInputField(icon: "person.fill",
                                             placeholder: "Enter Your Name",
                                             text: $name)
                            CustomInputField(
                                icon: "envelope.fill",
                                placeholder: "Enter Your Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            ValidationRequirement(text: "Invalid Email Address", isValid: isEmailValid())

                            CustomInputField(
                                icon: "lock.fill",
                                placeholder: "Enter Your Password",
                                text: $password,
                                isSecure: true,
                                isPasswordVisible: isPasswordVisible,
                                toggleVisibility: { isPasswordVisible.toggle() }
                            )

                            ValidationRequirement(text: "At least one uppercase letter", isValid: hasUppercase())
                            ValidationRequirement(text: "At least one lowercase letter", isValid: hasLowercase())
                            ValidationRequirement(text: "At least one digit", isValid: hasDigit())
                            ValidationRequirement(text: "One special character", isValid: hasSpecialCharacter())
                            ValidationRequirement(text: "At least 6 characters long", isValid: hasMinimumLength())
                            
                            HStack {
                                Button(action: {
                                    signUpUser() // call the sign up action
                                }, label: {
                                    if isSignUp {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .frame(maxWidth: .infinity, maxHeight: 35)
                                    } else {
                                        Text("Sign Up")
                                            .font(.headline)
                                            .frame(height: 35)
                                            .frame(maxWidth: .infinity)
                                            .background(isFormValid() ? Color.white : Color.white.opacity(0.3))
                                            .foregroundColor(isFormValid() ? .black : .gray)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                })
                                .disabled(!isFormValid() || isSignUp)
                                .padding(.horizontal)
                            }

                            if let signUpError = signUpError {
                                Text(signUpError)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(20)
                        .shadow(radius: 15)
                    }
                    Spacer()
                    Button("Back to Sign In") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
                    .font(.footnote)
                }
                .padding()
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
