import SwiftUI

struct IntroView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Binding var hasSeenIntro: Bool
    
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
                Spacer()
                
                Text("Welcome to ExploRO")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Please sign in to continue")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    hasSeenIntro = true
                    if authViewModel.user != nil {
                        authViewModel.signOut()
                    }
                }) {
                    Text("Continue")
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
        }
    }
}


#Preview {
    IntroView(hasSeenIntro: .constant(true))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
