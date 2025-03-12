
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        GeometryReader{geo1 in
            VStack{
                if let errorMessage = authViewModel.errorMessage{
                    Text(errorMessage)
                            .foregroundStyle(.red)
                }
                TextFieldView(fieldName: "Email", fieldData: $email)
                
                TextFieldView(fieldName: "Password", fieldData: $password)
                
                Button("Register"){
                    Task {
                        await authViewModel.register(email: email, password: password)
                    }
                }
                .frame(maxWidth: geo1.size.width * 0.91, minHeight: 50)
                .background(Color(red: 75/255.0, green: 217/255.0, blue: 209/255.0))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 2, x: 0, y: 4)
                .font(.custom("Poppins", size: 18))
                .padding(.top,15)
                
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
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}

