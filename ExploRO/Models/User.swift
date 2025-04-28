
import Foundation

struct UserResponse : Codable{
    let user: BackendUser
}

struct BackendUser: Codable {
    let Id: String
    let Name: String?
    let Email: String?
    let CreatedAt: String
    let DeletedAt: String?
}
