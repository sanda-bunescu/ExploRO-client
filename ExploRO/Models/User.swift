
import Foundation

struct UserResponse : Codable{
    let user: BackendUser
}

struct BackendUser: Codable {
    let ID: Int
    let FirebaseId: String
    let Name: String?
    let Email: String?
    let CreatedAt: String
    let DeletedAt: String?
}
