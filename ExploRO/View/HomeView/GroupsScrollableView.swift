import SwiftUI

struct GroupsScrollableView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var viewModel = GroupViewModel()
    var body: some View {
        VStack{
            HStack {
                Text("Groups")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                NavigationLink(destination: CreateGroupView(viewModel: viewModel)) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            ScrollView (.horizontal, showsIndicators: false){
                HStack {
                    ForEach(viewModel.groups, id: \.id) { group in
                        NavigationLink{
                            GroupView(groupViewModel: viewModel, group: group)
                        }label:{
                            VStack {
                                AsyncImage(url: URL(string: group.imageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 80, height: 80)

                                        Image(systemName: "person.3.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                    }
                                }

                                Text(group.groupName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                }
                .id(UUID())
            }
        }
        .padding()
        .task {
            await viewModel.fetchGroupsByUserId(user: authViewModel.user)
        }
    }
}

#Preview {
    NavigationStack{
        GroupsScrollableView()
    }.environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    
}
