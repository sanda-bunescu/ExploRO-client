
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        GeometryReader{geo1 in
            VStack{
                TextFieldView(fieldName: "Username", fieldData: $username)
                TextFieldView(fieldName: "Email", fieldData: $email)
                
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
                        .padding(.top,10)
                        .transition(.opacity)
                }
                Button("Register"){
                    Task {
                        await authViewModel.register(username: username, email: email, password: password)
                    }
                }
                .frame(maxWidth: geo1.size.width * 0.91, minHeight: 50)
                .background(Color(red: 75/255.0, green: 217/255.0, blue: 209/255.0))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 2, x: 0, y: 4)
                .font(.custom("Poppins", size: 18))
                .padding(.top,10)
                
                HStack {
                    VStack{
                        Divider()
                            .background(Color.gray)
                    }
                    Text("or continue with")
                        .font(.custom("Poppins", size: 13))
                        .foregroundColor(Color.gray)
                    VStack{
                        Divider()
                            .background(Color.gray)
                    }
                }
                .padding(20)
                HStack{
                    Button{
                        Task{
                            await authViewModel.loginWithGoogle()
                        }
                    }label: {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2, x: 0, y: 4)
                    .padding(.horizontal)
                    Button{
                        Task{
                            await authViewModel.loginWithFacebook()
                        }
                    }label: {
                        Image("facebook")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2, x: 0, y: 4)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                authViewModel.errorMessage = nil
                authViewModel.successMessage = nil
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}

