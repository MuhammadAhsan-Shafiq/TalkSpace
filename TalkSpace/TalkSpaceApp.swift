import SwiftUI
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Ensure this is present
        return true
    }
}

@main
struct TalkSpaceApp: App {
    @StateObject private var sessionManager = SessionManager()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // Register AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager) // Pass sessionManager to the views
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var authViewModel = AuthViewModel(sessionManager: SessionManager()) // Initialize the AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
       
    
    var body: some View {
        Group {
            if sessionManager.isLoggedIn {
                UsersScreenView()
                    .environmentObject(sessionManager)
            } else {
                LoginScreenView(viewModel: authViewModel)
                    .environmentObject(sessionManager)
            }
        }
        .overlay( // Overlay dark mode toggle buttom at the bottom
            VStack{
                Spacer()
                HStack{
                    Button(action: {
                        isDarkMode.toggle() // toggle dark mode on/off
                    }){
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 24))
                                                        .foregroundColor(isDarkMode ? .yellow : .blue)
                                                        .padding()
                    }
                    Spacer()
                }
                .padding(.bottom, 30) // Adjust bottom padding
                Spacer()
            }
        )
    }
}
