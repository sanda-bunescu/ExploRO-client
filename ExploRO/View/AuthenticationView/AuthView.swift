import SwiftUI


class AuthViewModel: ObservableObject {
    @Published var showLoginPage = true
    @Published var rectangleSize: CGFloat
        
        init() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.rectangleSize = 0.45
            } else {
                self.rectangleSize = 0.6
            }
        }

    
    func toggleToLogin() {
        withAnimation(.easeInOut) {
            showLoginPage = true
            rectangleSize = UIDevice.current.userInterfaceIdiom == .pad ? 0.45 : 0.6
        }
    }
    
    func toggleToRegister() {
        withAnimation(.easeInOut) {
            showLoginPage = false
            rectangleSize = UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 0.7
                
        }
    }
}


struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Image("Intro")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(Color.white)
                        .frame(height: UIScreen.main.bounds.height * viewModel.rectangleSize)
                        .clipShape(RoundedRectangle(cornerRadius: 45.0))
                        .padding(.bottom)
                        .overlay {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button("Login") {
                                        authViewModel.errorMessage = ""
                                        viewModel.toggleToLogin()
                                    }
                                    .font(.custom("Poppins", size: 19))
                                    .foregroundStyle(.black)
                                    Spacer()
                                    Button("Register") {
                                        authViewModel.errorMessage = ""
                                        viewModel.toggleToRegister()
                                    }
                                    .font(.custom("Poppins", size: 19))
                                    .foregroundStyle(.black)
                                    Spacer()
                                }
                                .padding()
                                
                                if viewModel.showLoginPage {
                                    LoginView()
                                } else {
                                    RegisterView()
                                }
                            }
                        }
                    Spacer()
                }
                .padding()
                .shadow(radius: 10)
            }
        }
        .previewInterfaceOrientation(.portrait)
    }
}


#Preview {
    AuthView(viewModel: AuthViewModel())
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
