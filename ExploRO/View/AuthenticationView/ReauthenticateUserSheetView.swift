import SwiftUI

struct ReauthenticateUserSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var enteredEmail = ""
    @State private var password = ""
    //@State private var worningText = ""
    @State private var showGoodbye = false
    var body: some View {
        NavigationStack {
            GeometryReader { geo1 in
                VStack {
                    Text("For your security, please reauthenticate before we can proceed with account deletion.")
                        .font(.custom("Poppins", size: 16))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top,20)
                    
                    TextFieldView(fieldName: "Email", fieldData: $enteredEmail)
                    //                    HStack{
                    //                        Spacer()
                    //                        Text(worningText)
                    //                            .font(.custom("Poppins", size: 14))
                    //                            .foregroundColor(.red)
                    //                            .padding(.horizontal)
                    //                            .padding(.top, 5)
                    //                    }
                    TextFieldView(fieldName: "Password", fieldData: $password)
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
                            if try await authViewModel.reauthenticateUserWithEmailAndPassword(email: enteredEmail, password: password){
                                
                                showGoodbye = true
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
                                        await authViewModel.deleteUser()
                                        
                                    }else{
                                        print("Error connecting with google. Verify if your account is connected with google.")
                                    }
                                }else{
                                    print("Wrong authentication method")
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
                                        await authViewModel.deleteUser()
                                        
                                    }else{
                                        print("error connecting with facebook. Verify if your account is connected with facebook.")
                                    }
                                }else{
                                    print("Wrong authentication method")
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
