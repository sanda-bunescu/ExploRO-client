import SwiftUI

struct AddUserGroupView: View {
    @ObservedObject var groupViewModel: GroupViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    let groupId: Int
    @State private var userEmail: String = ""
    @State private var showAlert = false
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter user email", text: $userEmail)
                    .padding()
                
                Button(action: {
                    Task {
                        await groupViewModel.addUserGroup(groupId: groupId, userEmail: userEmail, user: authViewModel.user)
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add User")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Group Member")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(groupViewModel.errorMessage ?? "Unknown error", isPresented: $showAlert) {
                Button("OK") {
                    if groupViewModel.errorMessage != "Email field cannot be empty"{
                        dismiss()
                    }
                }
            }
            .onChange(of: groupViewModel.errorMessage) { oldValue, newValue in
                if let _ = newValue {
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    AddUserGroupView(groupViewModel: GroupViewModel(), groupId: 4)
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
