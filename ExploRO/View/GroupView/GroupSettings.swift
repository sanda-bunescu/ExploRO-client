import SwiftUI

import SwiftUI

struct GroupSettings: View {
    var onGroupLeftOrDeleted: (() -> Void)?
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
        List {
            Section(header: Text("Group Members").font(.headline)) {
                Button {
                    showAddUserView = true
                } label: {
                    Label("Add Group Member", systemImage: "plus.circle.fill")
                        .font(.body)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showAddUserView) {
                    AddUserGroupView(groupViewModel: groupViewModel, groupId: group.id)
                }
                
                ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                    Button {
                        selectedMember = member
                        showSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading) {
                                Text(member.userName.isEmpty ? "Unknown" : member.userName)
                                    .font(.body)
                                    .bold()
                                    .foregroundColor(.black)
                                Text(member.userEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showLeaveGroupAlert = true
                } label: {
                    Label("Leave Group", systemImage: "arrow.left.circle")
                        .foregroundStyle(.red)
                }
                .alert("Leave Group", isPresented: $showLeaveGroupAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Leave", role: .destructive) {
                        Task {
                            await groupViewModel.leaveGroup(groupId: group.id, user: authViewModel.user)
                            dismiss()
                            onGroupLeftOrDeleted?()
                        }
                    }
                } message: {
                    Text("Are you sure you want to leave this group?")
                }
                
                Button(role: .destructive) {
                    showDeleteGroupAlert = true
                } label: {
                    Label("Delete Group", systemImage: "trash")
                        .foregroundStyle(.red)
                }
                .alert("Delete Group", isPresented: $showDeleteGroupAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        Task {
                            await groupViewModel.deleteGroup(groupId: group.id, user: authViewModel.user)
                            dismiss()
                            onGroupLeftOrDeleted?()
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this group?")
                }
            }
        }
        .navigationTitle(group.groupName)
        .navigationBarTitleDisplayMode(.inline)
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
    GroupSettings(groupViewModel: GroupViewModel(), group: GroupResponse(id: 86, groupName: "TestGroup", imageUrl: "http://localhost:3000/static/groupImages/Three Friends Walking in the City.jpeg"))
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
