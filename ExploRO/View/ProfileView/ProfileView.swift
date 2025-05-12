import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var showLogoutAlert = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                let user = authViewModel.user
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.green)
                        .frame(height: 250)
                        .overlay(
                            VStack(spacing: 10) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                
                                Text("Hi, \(user?.displayName ?? "User")!")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .bold()
                                
                                Text(user?.email ?? "Email")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                                .padding(.top, 50)
                        )
                }
                
                VStack(spacing: 1) {
                    ProfileRow(icon: "person.circle", color: .blue, title: "My Profile", destination: MyProfileView())
                    ProfileRow(icon: "key.fill", color: .orange, title: "Change Password", destination: ChangePasswordView())
                    ProfileRow(icon: "info.circle", color: .green, title: "About Us", destination: AboutUsView())
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Circle()
                                .fill(.purple.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.purple)
                                )
                            
                            Text("Log Out")
                                .font(.system(size: 16))
                                .padding(.leading, 5)
                                .foregroundStyle(Color.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    ProfileRow(icon: "trash", color: .pink, title: "Delete Account", destination: ReauthenticateUserSheetView())
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
                .shadow(radius: 3)
                
                Spacer()
            }
            .background(Color(hex: "#E2F1E5").ignoresSafeArea())
            .edgesIgnoringSafeArea(.top)
            .alert("Log out?", isPresented: $showLogoutAlert) {
                Button("Log out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}


struct LogoutView: View {
    var body: some View {
        Text("Are you sure you want to log out?")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
