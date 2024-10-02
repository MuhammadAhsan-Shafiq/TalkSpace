import SwiftUI


struct SignUpScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: SessionManager // Managing user sessions
    @StateObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme // Access current color scheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea() // Make sure it covers the entire screen
                VStack {
                    Text("TalkSpace")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Title color based on color scheme
                        .shadow(radius: 15)
                    Spacer()
                    VStack {
                        Text("Sign Up")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Sign Up title color
                            .shadow(radius: 15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            CustomInputField(icon: "person.fill",
                                             placeholder: "Enter Your Name",
                                             text: $viewModel.name)
                            CustomInputField(
                                icon: "envelope.fill",
                                placeholder: "Enter Your Email",
                                text: $viewModel.email,
                                keyboardType: .emailAddress
                            )
                            ValidationRequirement(text: "Invalid Email Address", isValid: viewModel.isEmailValid)
                            
                            CustomInputField(
                                icon: "lock.fill",
                                placeholder: "Enter Your Password",
                                text: $viewModel.password,
                                isSecure: true,
                                isPasswordVisible: viewModel.isPasswordVisible,
                                toggleVisibility: { viewModel.isPasswordVisible.toggle() }
                            )
                            
                            ValidationRequirement(text: "At least one uppercase letter", isValid: viewModel.hasUppercase)
                            ValidationRequirement(text: "At least one lowercase letter", isValid: viewModel.hasLowercase)
                            ValidationRequirement(text: "At least one digit", isValid: viewModel.hasDigit)
                            ValidationRequirement(text: "One special character", isValid: viewModel.hasSpecialCharacter)
                            ValidationRequirement(text: "At least 6 characters long", isValid: viewModel.hasMinimumLength)
                            
                            HStack {
                                Button(action: {
                                    viewModel.signUpUser()
                                }, label: {
                                    if viewModel.isSignUp {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .frame(maxWidth: .infinity, maxHeight: 35)
                                    } else {
                                        Text("Sign Up")
                                            .font(.headline)
                                            .frame(height: 35)
                                            .frame(maxWidth: .infinity)
                                            .background(viewModel.isFormValid ? Color.white : Color.white.opacity(0.3))
                                            .foregroundColor(viewModel.isFormValid ? .black : .gray)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                })
                                .disabled(!viewModel.isFormValid || viewModel.isSignUp)
                                .padding(.horizontal)
                            }
                            
                            if let signUpError = viewModel.signUpError {
                                Text(signUpError)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.black.opacity(0.1)) // Input field background
                        .cornerRadius(20)
                        .shadow(radius: 15)
                    }
                    Spacer()
                    Button("Back to Sign In") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Button color based on color scheme
                    .font(.footnote)
                }
                .padding()
                .onTapGesture {
                    UIApplication.shared.hideKeyboard()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
