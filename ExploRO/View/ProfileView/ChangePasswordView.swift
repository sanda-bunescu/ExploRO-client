import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.title2)
                .bold()
            
            HStack {
                if showCurrentPassword {
                    TextField("Current Password", text: $currentPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                } else {
                    SecureField("Current Password", text: $currentPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showCurrentPassword.toggle()
                }) {
                    Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                if showNewPassword {
                    TextField("New Password", text: $newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                } else {
                    SecureField("New Password", text: $newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showNewPassword.toggle()
                }) {
                    Image(systemName: showNewPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
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
            
            Button("Change Password") {
                Task {
                    await authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                    if authViewModel.successMessage != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authViewModel.errorMessage = nil
            authViewModel.successMessage = nil
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
