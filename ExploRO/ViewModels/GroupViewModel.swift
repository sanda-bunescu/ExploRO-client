import SwiftUI
import FirebaseAuth

@MainActor
class GroupViewModel: ObservableObject {
    @Published var groups: [GroupResponse] = []
    @Published var groupMembers: [GroupUserResponse] = []
    private let groupService: GroupService
    @Published var errorMessage: String?
    private var groupSymbols: [Int: String] = [:]
    
    @Published var searchText: String = ""
    var searchResults: [GroupResponse]{
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter { $0.groupName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    init(groupService: GroupService = GroupService()) {
        self.groupService = groupService
    }
    
    func fetchGroupsByUserId(user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            let idToken = try await user.getIDToken()
            let fetchedGroups = try await groupService.fetchGroupsByUserId(idToken: idToken)
            
            for group in fetchedGroups {
                if groupSymbols[group.id] == nil {
                    groupSymbols[group.id] = randomSFSymbol()
                }
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
        guard !groupName.isEmpty else {
            errorMessage = "Group name cannot be empty"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await groupService.createGroup(groupName: groupName, idToken: idToken)
            await fetchGroupsByUserId(user: user)
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
        }catch{
            errorMessage = "Failed to add user to group.\(groupService.errorMessageToShow)"
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
        }catch{
            errorMessage = "Failed to delete user from group.\(groupService.errorMessageToShow)"
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
        }catch{
            errorMessage = "Failed to leave group.\(groupService.errorMessageToShow)"
        }
    }
    
    private func randomSFSymbol() -> String {
        let symbols = ["airplane", "map", "car.2", "globe.europe.africa.fill", "rainbow", "mountain.2", "leaf"]
        return symbols.randomElement() ?? "map"
    }
    func symbol(for group: GroupResponse) -> String {
        return groupSymbols[group.id] ?? "person.3"
    }
}
