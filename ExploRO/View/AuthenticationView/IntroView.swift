import SwiftUI

struct IntroView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Binding var hasSeenIntro: Bool
    @State private var currentPage = 0
    @State private var slideOut = false
    var body: some View {
        ZStack {
            // Background image
            Image("Intro")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.black.opacity(0.1)],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            VStack(alignment: .center, spacing: 20) {
                VStack {
                    Spacer()
                    
                    TabView(selection: $currentPage) {
                        VStack(spacing: 20) {
                            Text("Welcome to ExploRO")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your adventure begins here")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tag(0)
                        
                        VStack(spacing: 20) {
                            Text("Discover New Destinations")
                                .font(.system(size: 27, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Find hidden gems, plan your trips, and create unforgettable memories.")
                                .font(.system(size: 24, weight: .regular))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .tag(1)
                        
                        VStack(spacing: 20) {
                            Text("Ready to Explore?")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Sign in to unlock your travel journey")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 300)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            slideOut = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            hasSeenIntro = true
                            if authViewModel.user != nil {
                                authViewModel.signOut()
                            }
                        }
                        
                    }) {
                        Text(currentPage == 2 ? "Continue" : "Skip")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.cyan)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        
                        
                    }
                    .padding(.bottom, 50)
                }
                .padding()
                .offset(x: slideOut ? -UIScreen.main.bounds.width : 0)
                
            }
            .padding()
        }
    }
}


#Preview {
    IntroView(hasSeenIntro: .constant(true))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
