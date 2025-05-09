import SwiftUI

struct GroupListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @StateObject private var viewModel = GroupViewModel()
    @State private var isCreateGroupPresented = false
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("My Groups")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()

                        if isSearching {
                            Button(action: {
                                withAnimation {
                                    isSearching = false
                                    viewModel.searchText = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Button {
                                withAnimation {
                                    isSearching = true
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 57/255, green: 133/255, blue: 72/255))
                            }
                        }
                    }
                    .padding(.horizontal)

                    if isSearching {
                        TextField("Search groups...", text: $viewModel.searchText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.searchResults, id: \.id) { group in
                                NavigationLink {
                                    GroupView(groupViewModel: viewModel, group: group)
                                } label: {
                                    HStack(spacing: 16) {
                                        AsyncImage(url: URL(string: group.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 60, height: 60)

                                                Image(systemName: "person.3.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.gray)
                                            }
                                        }

                                        Text(group.groupName)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Floating Create Group Button
                Button(action: {
                    isCreateGroupPresented = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 57/255, green: 133/255, blue: 72/255))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
                .fullScreenCover(isPresented: $isCreateGroupPresented) {
                    CreateGroupView(viewModel: viewModel)
                }
            }
            .navigationTitle("")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .task {
                await viewModel.fetchGroupsByUserId(user: authViewModel.user)
            }
        }
    }
}

#Preview {
    GroupListView()
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
