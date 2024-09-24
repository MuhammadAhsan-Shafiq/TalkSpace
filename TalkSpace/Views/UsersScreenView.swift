import SwiftUI


// struct to handle any sign in errors and display them
struct SignInError: Identifiable {
    var id: String { message } // Use the message itself as the unique identifier
    let message: String
}

//Main screen to display the list of users
struct UsersScreenView: View {
    @StateObject private var viewModel = UsersViewModel()
    
    @Environment(\.dismiss) var dismiss // Environment to manage view dismissal
    
    var body: some View {
        NavigationStack {
            VStack {
                if let currentUser = viewModel.currentUser {
                    // Display the current user's name (Safely unwrapped)
                    Text(currentUser.name)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(radius: 15)
                } else {
                    Text("Loading User...")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(radius: 15)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading....")
                } else {
                    List(viewModel.users) { user in
                        if user.email != viewModel.currentUser?.email { // Exclude the current user from the chat list
                            let chatId = viewModel.getChatId(with: user) // Generate chat ID
                            NavigationLink(destination: ChatView(user: user, chatId: chatId)) {
                                UserRowView(user: user)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationBarBackButtonHidden()
                    
                    // Logout button
                    Button(action: {
                        viewModel.handleLogout() // Handle logout action
                        dismiss()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .frame(width: 100, height: 35)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .alert(item: Binding(
                get: { viewModel.signInError.map { SignInError(message: $0) }},
                set: { _ in viewModel.signInError = nil }
            )) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}
#Preview {
    UsersScreenView()
}
