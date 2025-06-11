import SwiftUI

struct ReauthenticateUserSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var enteredEmail = ""
    @State private var password = ""
    @State private var showGoodbye = false
    @State private var showCurrentPassword = false
    var body: some View {
        NavigationStack {
            GeometryReader { geo1 in
                VStack {
                    Text("For your security, please reauthenticate before we can proceed with account deletion. Please note that all data connected to your account will be permanently deleted and cannot be recovered.")
                        .font(.custom("Poppins", size: 16))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical,20)
                    
                    TextFieldView(fieldName: "Email", fieldData: $enteredEmail)
                    VStack(alignment: .leading) {
                        Text("Password")

                        ZStack(alignment: .trailing) {
                            if showCurrentPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }

                            Button(action: {
                                showCurrentPassword.toggle()
                            }) {
                                Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing,1)
                        }
                        .padding()
                        .background(Color(red: 241/255.0, green: 241/255.0, blue: 241/255.0))
                        .clipShape(RoundedRectangle(cornerRadius: 15.0))
                        .shadow(radius: 2, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    if let errorMessage = authViewModel.errorMessage{
                        Text(errorMessage)
                            .font(.custom("Poppins", size: 14))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .transition(.opacity)
                    }
                    Button("Login") {
                        Task {
                            if authViewModel.verifyUserProvider(provider: "password"){
                                if try await authViewModel.reauthenticateUserWithEmailAndPassword(email: enteredEmail, password: password){
                                    showGoodbye = true
                                }
                            }else{
                                authViewModel.errorMessage = "Wrong authentication method"
                            }
                        }
                    }
                    .frame(maxWidth: geo1.size.width * 0.91, minHeight: 50)
                    .background(Color(red: 75/255.0, green: 217/255.0, blue: 209/255.0))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .shadow(radius: 2, x: 0, y: 4)
                    .font(.custom("Poppins", size: 18))
                    .padding(.top, 10)
                    
                    
                    HStack {
                        VStack {
                            Divider()
                                .background(Color.gray)
                        }
                        Text("or continue with")
                            .font(.custom("Poppins", size: 13))
                            .foregroundColor(Color.gray)
                        VStack {
                            Divider()
                                .background(Color.gray)
                        }
                    }
                    .padding(20)
                    
                    HStack {
                        Button {
                            Task{
                                if authViewModel.verifyUserProvider(provider: "google.com"){
                                    if try await authViewModel.reauthenticateUserWithGoogle(){
                                        showGoodbye = true
                                    }else{
                                        authViewModel.errorMessage = "Unknown error occurred. Please try again later."
                                    }
                                }else{
                                    authViewModel.errorMessage = "Wrong authentication method"
                                }
                            }
                        } label: {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 50, height: 50)
                        .shadow(radius: 2, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        Button {
                            Task{
                                if authViewModel.verifyUserProvider(provider: "facebook.com"){
                                    if try await authViewModel.reauthenticateUserWithFacebook(){
                                        showGoodbye = true
                                        
                                    }else{
                                        authViewModel.errorMessage = "Unknown error occurred. Please try again later."
                                    }
                                }else{
                                    authViewModel.errorMessage = "Wrong authentication method"
                                }
                                
                            }
                        } label: {
                            Image("facebook")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 50, height: 50)
                        .shadow(radius: 2, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Reauthenticate")
                .onAppear {
                    authViewModel.errorMessage = nil
                    authViewModel.successMessage = nil
                }
                .alert("Goodbye", isPresented: $showGoodbye) {
                    Button("Cancel", role: .cancel) {
                        
                    }
                    Button("OK", role: .destructive) {
                        Task {
                            await authViewModel.deleteUser()
                        }
                    }
                } message: {
                    Text("We're sad to see you go. You're always welcome back anytime!")
                }
                
            }
        }
    }
}

#Preview {
    ReauthenticateUserSheetView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
