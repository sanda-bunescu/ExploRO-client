import SwiftUI
import FirebaseAuth

@MainActor
class GroupViewModel: ObservableObject {
    @Published var groups: [GroupResponse] = []
    @Published var groupMembers: [GroupUserResponse] = []
    private let groupService: GroupServiceProtocol
    @Published var errorMessage: String?
    @Published var showAlert = false
    
    @Published var searchText: String = ""
    var searchResults: [GroupResponse]{
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter { $0.groupName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init(groupService: GroupServiceProtocol = GroupService()) {
        self.groupService = groupService
    }
    
    func fetchGroupsByUserId(user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            let idToken = try await user.getIDToken()
            var fetchedGroups = try await groupService.fetchGroupsByUserId(idToken: idToken)
            
            fetchedGroups = fetchedGroups.map { group in
                var modifiedGroup = group
                if let imageUrl = group.imageUrl, !imageUrl.isEmpty {
                    modifiedGroup.imageUrl = "\(AppConfig.baseURL)\(imageUrl)"
                }
                return modifiedGroup
            }
            
            self.groups = fetchedGroups
        } catch {
            errorMessage = "Failed to fetch groups"
        }
    }
    
    func createGroup(groupName: String, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        if groupName.isEmpty {
            errorMessage = "Please enter group name"
            showAlert = true
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await groupService.createGroup(groupName: groupName, idToken: idToken)
            await fetchGroupsByUserId(user: user)
            errorMessage = "Group created successfully"
            showAlert = true
        } catch {
            errorMessage = "Failed to create group"
        }
    }
    
    func deleteGroup(groupId: Int, user: User?) async{
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            let idToken = try await user.getIDToken()
            try await groupService.deleteGroup(groupId: groupId, idToken: idToken)
            await fetchGroupsByUserId(user: user)
        } catch {
            errorMessage = "Failed to delete group"
        }
    }
    
    func fetchUsersByGroupId(groupId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedUsers = try await groupService.fetchUsersByGroupId(groupId: groupId, idToken: idToken)
            self.groupMembers = fetchedUsers 
        } catch {
            errorMessage = "Failed to fetch group members"
        }
    }
    
    func addUserGroup(groupId: Int, userEmail: String, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        guard !userEmail.isEmpty else {
            errorMessage = "Email field cannot be empty"
            return
        }
        
        do{
            let idToken = try await user.getIDToken()
            try await groupService.addUserGroup(groupId: groupId, userEmail: userEmail, idToken: idToken)
            await fetchUsersByGroupId(groupId: groupId, user: user)
            errorMessage = "User added successfully"
        } catch let error as GroupError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    func deleteUserGroup(groupId: Int, userEmail: String, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do{
            let idToken = try await user.getIDToken()
            try await groupService.deleteUserGroup(groupId: groupId, userEmail: userEmail, idToken: idToken)
            await fetchUsersByGroupId(groupId: groupId, user: user)
            errorMessage = "User deleted successfully"
        } catch let error as GroupError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    
    func leaveGroup(groupId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        guard let userEmail = user.email else{
            errorMessage = "User email could not be retrieved. Please try again later."
            return
        }
        do{
            let idToken = try await user.getIDToken()
            try await groupService.deleteUserGroup(groupId: groupId, userEmail: userEmail, idToken: idToken)
            await fetchGroupsByUserId(user: user)
        } catch let error as GroupError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }
    
}
