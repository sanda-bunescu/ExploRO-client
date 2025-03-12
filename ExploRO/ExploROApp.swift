import SwiftUI
import FirebaseCore
import FBSDKCoreKit

@main
struct ExploROApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel1 = AuthenticationViewModel1(
            firebaseService: FirebaseAuthentication(),
            authService: AuthService()
        )
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel1)
        }
    }
}
