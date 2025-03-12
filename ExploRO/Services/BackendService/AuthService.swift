import Foundation

enum BackendAction{
    case createUser
    case loginUser
    case deleteUser
}

protocol AuthServiceProtocol{
    func sendIdTokenToBackend(idToken: String, for action: BackendAction)
}

class AuthService: AuthServiceProtocol{
    func sendIdTokenToBackend(idToken: String, for action: BackendAction){
        print(idToken)//delete this
        var urlString: String
        switch action{
        case .createUser:
            urlString = "http://localhost:3000/create-user"
        case .loginUser:
            urlString = "http://localhost:3000/login-user"
        case .deleteUser:
            urlString = "http://localhost:3000/delete-user"
        }
        guard let url = URL(string: urlString) else{
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){data, response, error in
            if let error = error{
                print("Error sending the request \(error)")
                return
            }
            if let data = data{
                do{
                    let decoder = JSONDecoder()
                    let userResponse = try decoder.decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        print(userResponse.user)
                    }
                }catch{
                    print("error decoding backend User object")
                }
            }
        }
        task.resume()
        
    }
}
