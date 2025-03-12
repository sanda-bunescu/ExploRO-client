import SwiftUI

struct GroupListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var viewModel = GroupViewModel()
    @State private var isCreateGroupPresented = false
    @State private var isSearching = false
    var body: some View {
        NavigationView {
            VStack {
                Text("Groups")
                    .font(.title)
                    .bold()
                    .foregroundColor(.blue)
                
                HStack {
                    if isSearching {
                        TextField("Search groups...", text: $viewModel.searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .transition(.move(edge: .trailing).combined(with: .opacity)) // Smooth animation
                            .animation(.easeInOut(duration: 0.3), value: isSearching)

                        Button(action: {
                            withAnimation {
                                isSearching = false
                                viewModel.searchText = "" // Reset search when closed
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    } else {
                        Button{
                            withAnimation {
                                isSearching = true
                            }
                        }label:{
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .background(Circle().fill(Color(.systemGray5)))
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults, id: \.id) { group in
                            NavigationLink{
                                GroupView(groupViewModel: viewModel, group: group)
                            }label:{
                                HStack {
                                    Image(systemName: viewModel.symbol(for: group))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.gray)
                                        .padding(7)
                                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                                    Text(group.groupName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                    Button{
                        isCreateGroupPresented = true
                    }label: {
                        Text("Create Group")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .fullScreenCover(isPresented: $isCreateGroupPresented) {
                        CreateGroupView(viewModel: viewModel)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchGroupsByUserId(user: authViewModel.user)
        }
        
    }
}

#Preview {
    GroupListView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
