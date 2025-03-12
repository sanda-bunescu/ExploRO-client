import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName: String = ""
    @ObservedObject var viewModel: GroupViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    var body: some View {
        ZStack {
            Image("Intro")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                Spacer()
                TextField("Enter Group Name", text: $groupName)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)
                    .background(Color.white.opacity(0.9))                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                
                Button{
                    Task{
                        await viewModel.createGroup(groupName: groupName, user: authViewModel.user)
                    }
                    dismiss()
                }label:{
                    Text("Create Group")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    CreateGroupView(viewModel: GroupViewModel())
}
