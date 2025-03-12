import Foundation
enum GroupError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
    case userAlreadyAdded
}

protocol GroupServiceProtocol {
    func fetchGroupsByUserId(idToken: String) async throws -> [GroupResponse]
    func fetchUsersByGroupId(groupId: Int, idToken: String) async throws -> [GroupUserResponse]
    func createGroup(groupName: String, idToken: String) async throws
    func deleteGroup(groupId: Int, idToken: String) async throws
    func addUserGroup(groupId: Int,userEmail: String, idToken:String) async throws
    func deleteUserGroup(groupId: Int,userEmail: String, idToken:String) async throws
}

class GroupService: GroupServiceProtocol {
    private let baseURL = "http://localhost:3000"
    @Published var errorMessageToShow = ""
    func fetchGroupsByUserId(idToken: String) async throws -> [GroupResponse] {
        guard let url = URL(string: "\(baseURL)/get-groups-by-userid") else {
            throw GroupError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GroupError.requestFailed
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let groupsResponse = try decoder.decode([String: [GroupResponse]].self, from: data)
            
            return groupsResponse["user_groups"] ?? []
        } catch {
            throw GroupError.requestFailed
        }
    }
    
    func fetchUsersByGroupId(groupId: Int, idToken: String) async throws -> [GroupUserResponse] {
        guard let url = URL(string: "\(baseURL)/get-users-by-groupid?id=\(groupId)") else {
            throw GroupError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GroupError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let usersResponse = try decoder.decode([String: [GroupUserResponse]].self, from: data)
            
            return usersResponse["users"] ?? []
        } catch {
            throw GroupError.requestFailed
        }
    }
    
    
    func createGroup(groupName: String, idToken: String) async throws  {
        guard let url = URL(string: "\(baseURL)/create-group") else {
            throw GroupError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let groupData = NewGroupRequest(name: groupName)
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let jsonData = try encoder.encode(groupData)
            request.httpBody = jsonData
        } catch {
            throw GroupError.encodingError
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GroupError.requestFailed
            }
        } catch {
            throw GroupError.requestFailed
        }
    }
    
    func deleteGroup(groupId: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/delete-group?id=\(groupId)") else {
            throw GroupError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GroupError.requestFailed
            }
        } catch {
            throw GroupError.requestFailed
        }
    }
    
    func addUserGroup(groupId: Int,userEmail: String, idToken:String) async throws{
        guard let url = URL(string: "\(baseURL)/add-user-groups") else {
            throw GroupError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userGroupToAdd = ModifyUserGroupRequest(groupId: groupId, userEmail: userEmail)
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let jsonData = try encoder.encode(userGroupToAdd)
            request.httpBody = jsonData
        } catch {
            throw GroupError.encodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    errorMessageToShow = errorMessage
                }
                throw GroupError.requestFailed
            }
        }catch {
            throw GroupError.requestFailed
        }
    }
    
    func deleteUserGroup(groupId: Int,userEmail: String, idToken:String) async throws{
        guard let url = URL(string: "\(baseURL)/delete-user-groups") else {
            throw GroupError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userGroupToAdd = ModifyUserGroupRequest(groupId: groupId, userEmail: userEmail)
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let jsonData = try encoder.encode(userGroupToAdd)
            request.httpBody = jsonData
        } catch {
            throw GroupError.encodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    errorMessageToShow = errorMessage
                }
                throw GroupError.requestFailed
            }
        }catch {
            throw GroupError.requestFailed
        }
    }
    
    
    
}
