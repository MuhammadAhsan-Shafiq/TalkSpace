import SwiftUI

// Struct to handle any sign-in errors and display them
struct SignInError: Identifiable {
    var id: String { message } // Use the message itself as the unique identifier
    let message: String
}

// Main screen to display the list of users and tabbed navigation
struct UsersScreenView: View {
    @StateObject private var viewModel = UsersViewModel()
    @State private var metaAI: String = ""
    @State private var selectedTab: Tab = .chat // State to track the selected tab
    
    enum Tab {
        case chat
        case updates
        case communities
        case calls
    }
    
    @Environment(\.dismiss) var dismiss // Environment to manage view dismissal
    
    // Custom accent color
    private let customAccentColor: Color = Color(red: 0.0, green: 0.5, blue: 0.0) // Dark green
    
    
    var body: some View {
        NavigationStack{
            VStack{
                // Main content view based on the selected tab
                switch selectedTab {
                case .chat:
                    chatTab
                        .overlay(
                        floatingButtons
                        )
                case .updates:
                    updatesTab
                case .communities:
                    communitiesTab
                case .calls:
                    callsTab
                }
                
                Spacer() // Pushes the content up, leaving space for the tab bar
                

                
                // Custom Tab Bar
                HStack {
                    tabButton(title: "Chat", selectedImage: "bubble.left.fill",unselectedImage: "bubble.left", tab: .chat)
                    tabButton(title: "Updates", selectedImage: "circle.dashed.inset.filled",unselectedImage: "circle.dashed", tab: .updates)
                    tabButton(title: "Communities", selectedImage: "person.3.fill",unselectedImage: "person.3", tab: .communities)
                    tabButton(title: "Calls", selectedImage: "phone.fill",unselectedImage: "phone", tab: .calls)
                }
                .padding(.bottom, 10) // Add padding to the bottom of the tab bar
            }
        }
    }
    
    // MARK: - Chat Tab View
    private var chatTab: some View {
        NavigationStack {
            VStack {
                headerView
                searchField
                if viewModel.isLoading {
                    ProgressView("Loading....")
                } else {
                    chatList
                }
            }
            .padding()
            .alert(item: Binding(
                get: { viewModel.signInError.map { SignInError(message: $0) }},
                set: { _ in viewModel.signInError = nil }
            )) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: Floating buttons
    private var floatingButtons: some View {
        VStack {
            Spacer() // Push buttons to the bottom
            HStack {
                Spacer() // Push the buttons to the right
                VStack {
                    Button(action: {
                        // Your action for Button 1
                    }) {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 30, height: 30) // Set a size for the image
                            .padding()
                            .background(Color.white)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue, Color.pink]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15) // Use corner radius to round the image background
                    }
                    .padding(.bottom, 5)
                    .shadow(radius: 10)
                    
                    Button(action: {
                        // Your action for Button 2
                    }, label: {
                        Image(systemName: "plus.rectangle.fill")
                            .resizable()
                            .frame(width: 35, height: 25) // Set a size for the image
                            .padding(.all, 15)
                            .background(customAccentColor)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    })
                }
            }
            .padding([.bottom, .trailing], 20) // Padding for spacing at the bottom-right corner
        }
    }
    
    
    // MARK: - Custom Tab Button
    private func tabButton(title: String, selectedImage: String, unselectedImage: String, tab: Tab) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack {
                Image(systemName: selectedTab == tab ? selectedImage : unselectedImage)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == tab ? customAccentColor : Color.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .background(selectedTab == tab ? customAccentColor.opacity(0.2) : Color.clear) // Background color based on selection
                    .cornerRadius(10)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(selectedTab == tab ? customAccentColor : Color.black)
                    .fontWeight(selectedTab == tab ? .bold : .regular)
            }
        }
        .frame(maxWidth: .infinity) // Make buttons occupy equal space
    }
    

    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            if let currentUser = viewModel.currentUser {
                Text(currentUser.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(customAccentColor)
                    .shadow(radius: 15)
            } else {
                Text("Loading User...")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(customAccentColor)
                    .shadow(radius: 15)
            }
            Spacer()
            settingsMenu
        }
    }
    
    // MARK: - Search Field
    private var searchField: some View {
        HStack {
            Image(systemName: "circle")
                .font(.largeTitle)
                .bold()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan, Color.blue, Color.pink]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image(systemName: "circle")
                            .font(.largeTitle)
                            .bold()
                    )
                )
            
            TextField("Ask Meta AI or Search", text: $metaAI)
                .padding(.leading, 10)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(30)
    }
    
    // MARK: - Chat List
    private var chatList: some View {
        List {
            ForEach(viewModel.users) { user in
                if user.email != viewModel.currentUser?.email { // Exclude the current user from the chat list
                    if let currentUser = viewModel.currentUser {
                        NavigationLink(destination: ChatView(user: currentUser, otherUser: user, chatId: viewModel.getChatId(with: user))) {
                            chatRow(for: user)
                        }
                        .background(Color.clear) // Make the background clear
                    } else {
                        // Optionally handle the case where currentUser is nil, if needed
                        Text("User data is not available")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    
    // MARK: - Chat Row View
    private func chatRow(for user: User) -> some View {
        HStack {
            UserRowView(user: user,timeStamp: nil) // No last message or timestamp
                .padding(.vertical, 10) // Add vertical padding for spacing
            Spacer()
        }
    }
    
    // MARK: - Settings Menu
    private var settingsMenu: some View {
        HStack(spacing: 30) {
            Image(systemName: "camera")
            
            Menu {
                Button(action: {
                    viewModel.handleLogout() // Handle logout action
                    dismiss()
                }) {
                    Text("Logout")
                        .font(.headline)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(Angle(degrees: 90))
            }
        }
        .fontWeight(.bold)
    }
    
    // MARK: - Updates Tab View
    private var updatesTab: some View {
        Text("Updates View")
            .font(.largeTitle)
            .foregroundColor(.black)
    }
    
    // MARK: - Communities Tab View
    private var communitiesTab: some View {
        Text("Communities View")
            .font(.largeTitle)
            .foregroundColor(.black)
    }
    
    // MARK: - Calls Tab View
    private var callsTab: some View {
        Text("Calls View")
            .font(.largeTitle)
            .foregroundColor(.black)
    }
}

#Preview {
    UsersScreenView()
}
