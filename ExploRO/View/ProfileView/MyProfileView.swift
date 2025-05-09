import SwiftUI
import FirebaseAuth

struct MyProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    
    var body: some View {
        let user = authViewModel.user
        
        VStack(spacing: 30) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.green)
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Name:")
                        .fontWeight(.bold)
                    Spacer()
                    Text(user?.displayName ?? "Not available")
                }
                
                HStack {
                    Text("Email:")
                        .fontWeight(.bold)
                    Spacer()
                    Text(user?.email ?? "Not available")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    MyProfileView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
