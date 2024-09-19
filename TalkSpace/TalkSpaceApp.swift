import SwiftUI
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TalkSpaceApp: App {
    @StateObject private var sessionManager = SessionManager()
    
    // Register AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager) // Pass sessionManager to the views
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Group {
            if sessionManager.isLoggedIn {
                UsersScreenView()
                    .environmentObject(sessionManager)
            } else {
                LoginScreenView()
                    .environmentObject(sessionManager)
            }
        }
    }
}
