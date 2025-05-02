import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State var email: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        GeometryReader{ geo in
            VStack{
                Spacer()
                TextFieldView(fieldName: "Email", fieldData: $email)
                if let successMessage = authViewModel.successMessage, !successMessage.isEmpty{
                    Text(successMessage)
                        .font(.custom("Poppins", size: 14))
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .transition(.opacity)
                } else if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty{
                    Text(errorMessage)
                        .font(.custom("Poppins", size: 14))
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                Button{
                    Task {
                        await authViewModel.resetPassword(email: email)
                        if authViewModel.successMessage != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                    }
                }label: {
                    Text("Reset Password")
                }
                .frame(maxWidth: geo.size.width * 0.91, minHeight: 50)
                .background(Color(red: 75/255.0, green: 217/255.0, blue: 209/255.0))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 2, x: 0, y: 4)
                .font(.custom("Poppins", size: 18))
                .padding(.top, 10)
                
                Button{
                    dismiss()
                }label: {
                    Text("Cancel")
                }
                .frame(maxWidth: geo.size.width * 0.91, minHeight: 50)
                .background(Color.gray.opacity(0.07))
                .foregroundStyle(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .shadow(radius: 2, x: 0, y: 4)
                .font(.custom("Poppins", size: 18))
                .padding(.top, 10)
                Spacer()
                
            }
            .onAppear {
                authViewModel.errorMessage = nil
                authViewModel.successMessage = nil
            }
        }
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
