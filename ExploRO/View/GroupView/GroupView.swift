import SwiftUI

struct GroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var groupViewModel: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    let group: GroupResponse
    @State private var showAddUserView = false
    @State private var showLeaveGroupAlert = false
    @State private var showDeleteGroupAlert = false
    @State private var showSheet = false
    @State private var selectedMember: GroupUserResponse?
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: groupViewModel.symbol(for: group))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .clipped()
                
                Text(group.groupName)
                
                Spacer()
            }
            .bold()
            .font(.title2)
            .frame(height: 50)
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Group Members")
                    .font(.title3)
                    .bold()
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .background(Color.white)
            ScrollView {
                Button{
                    showAddUserView = true
                    
                }label:{
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Group Member")
                        Spacer()
                    }
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showAddUserView) {
                    AddUserGroupView(groupViewModel: groupViewModel, groupId: group.id)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                        Button {
                            showSheet = true
                            selectedMember = member
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading) {
                                    Text(member.userName.isEmpty ? "Unknown" : member.userName)
                                        .foregroundStyle(.black)
                                    Text(member.userEmail)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        }
                    }
                }
                .padding()
                Button{
                    showLeaveGroupAlert = true
                    
                }label:{
                    HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("Leave Group")
                        Spacer()
                    }
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .alert("Leave Group", isPresented: $showLeaveGroupAlert) {
                    Button("Cancel") {}
                    Button("Leave") {
                        Task {
                            await groupViewModel.leaveGroup(groupId: group.id, user: authViewModel.user)
                            dismiss()
                        }
                    }
                } message: {
                    Text("Are you sure you want to leave this group?")
                }
                Button{
                    showDeleteGroupAlert = true
                }label:{
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Group")
                        Spacer()
                    }
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .alert("Delete Group", isPresented: $showDeleteGroupAlert) {
                    Button("Cancel") {}
                    Button("Delete") {
                        Task {
                            await groupViewModel.deleteGroup(groupId: group.id, user: authViewModel.user)
                            dismiss()
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this group?")
                }
            }
        }
        .navigationTitle("Group settings")
        .onAppear {
            Task {
                await groupViewModel.fetchUsersByGroupId(groupId: group.id, user: authViewModel.user)
            }
        }
        .sheet(isPresented: $showSheet) {
            if let selectedMember = selectedMember {
                BottomSheet(member: selectedMember, groupViewModel: groupViewModel, group: group)
                    .presentationDetents([.fraction(0.1)])
            }
            Text(selectedMember?.userName ?? "No member selected")
        }
        .onChange(of: selectedMember?.userId, { oldValue, newValue in
            showSheet = newValue != nil
        })
    }
}

struct BottomSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    let member: GroupUserResponse
    @ObservedObject var groupViewModel: GroupViewModel
    let group: GroupResponse
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Button{
                Task {
                    await groupViewModel.deleteUserGroup(groupId: group.id, userEmail: member.userEmail, user: authViewModel.user)
                    dismiss()
                }
                presentationMode.wrappedValue.dismiss()
            }label: {
                Text("Remove \(member.userEmail) from \(group.groupName)")
                    .foregroundStyle(.red)
            }
        }
    }
}


#Preview {
    GroupView(groupViewModel: GroupViewModel(), group: GroupResponse(id: 4, groupName: "Test Group"))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
