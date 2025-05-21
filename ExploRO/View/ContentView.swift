import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    @State private var selectedTab: TabItem = .home
    var body: some View {
        if !hasSeenIntro {
            IntroView(hasSeenIntro: $hasSeenIntro)
        }else{
            switch authViewModel.authenticationState {
            case .authenticated:
                ToolbarContainer(selectedTab: $selectedTab) {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .trips:
                        TripPlanListView()
                    case .groups:
                        GroupListView()
                    case .profile:
                        ProfileView()
                    }
                }
            case .authenticating:
                ProgressView("Authenticating...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            case .unauthenticated:
                AuthView(viewModel: AuthViewModel())
                    .onAppear {
                        selectedTab = .home
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
