
import FirebaseAuth
import Foundation
import SwiftUI

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

@MainActor
class AuthenticationViewModel1: ObservableObject {
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var user: User?
    @Published var errorMessage : String?
    
    private let firebaseService: FirebaseAuthenticationProtocol
    private let backendService: AuthServiceProtocol
    
    init(firebaseService: FirebaseAuthenticationProtocol, authService: AuthServiceProtocol) {
        self.firebaseService = firebaseService
        self.backendService = authService
        checkAuthenticationState()
    }
    func checkAuthenticationState() {
        if let currentUser = Auth.auth().currentUser {
            user = currentUser
            authenticationState = .authenticated
            
        }else{
            authenticationState = .unauthenticated
        }
    }
    
    func login(email: String, password: String) async {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            return
        }
        authenticationState = .authenticating
        do {
            let firUser = try await firebaseService.loginWithEmailAndPassword(with: email, password: password)
            self.user = firUser
            authenticationState = .authenticated
            if let idToken = try? await firUser.getIDToken() {
                backendService.sendIdTokenToBackend(idToken: idToken, for: .loginUser)
            }
            errorMessage = ""
        } catch {
            authenticationState = .unauthenticated
            errorMessage = "Wrong email or password";
        }
    }
    
    func register(email: String, password: String) async {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            return
        }
        do {
            let firUser = try await firebaseService.registerWithEmailAndPassword(with: email, password: password)
            self.user = firUser
            authenticationState = .authenticated
            if let idToken = try? await firUser.getIDToken() {
                backendService.sendIdTokenToBackend(idToken: idToken, for: .createUser)
            }
            errorMessage = nil
        } catch let error as NSError {
            authenticationState = .unauthenticated
            errorMessage = mapFirebaseAuthError(error)
        }
    }
    
    func signOut() {
        do {
            try firebaseService.logout()
            self.user = nil
            authenticationState = .unauthenticated
        } catch {
            authenticationState = .authenticated
        }
    }
    
    func deleteUser() async {
        do {
            if let idToken = try? await user?.getIDToken() {
                backendService.sendIdTokenToBackend(idToken: idToken, for: .deleteUser)
                print(idToken)
            }
            try await firebaseService.deleteUser()
            try firebaseService.logout()
            self.user = nil
            authenticationState = .unauthenticated
        } catch {
            authenticationState = .authenticated
        }
    }
    
    func loginWithGoogle() async {
        do {
            let firUser = try await firebaseService.loginWithGoogle()
            authenticationState = .authenticated
            if let idToken = try? await firUser.getIDToken() {
                backendService.sendIdTokenToBackend(idToken: idToken, for: .createUser)
            }
            self.user = firUser
        } catch {
            authenticationState = .unauthenticated
        }
    }
    
    func loginWithFacebook() async {
        do {
            let firUser = try await firebaseService.loginWithFacebook()
            authenticationState = .authenticated
            if let idToken = try? await firUser.getIDToken() {
                backendService.sendIdTokenToBackend(idToken: idToken, for: .createUser)
            }
            self.user = firUser
        } catch {
            authenticationState = .unauthenticated
        }
    }
    
    func reauthenticateUserWithEmailAndPassword(email: String, password: String) async throws -> Bool{
        do{
            user = try await firebaseService.reauthenticateUserWithEmailAndPassword(with: email, password: password)
            errorMessage = ""
            return true
        }catch{
            errorMessage = "Wrong email or password"
            return false
        }
        
    }
    func reauthenticateUserWithGoogle() async throws  -> Bool{
        do{
            user = try await firebaseService.reauthenticateUserWithGoogle()
            return true
        }catch{
            print("Reauthentication error")
            return false
        }
        
    }
    func reauthenticateUserWithFacebook() async throws  -> Bool{
        do{
            user = try await firebaseService.reauthenticateUserWithFacebook()
            return true
        }catch{
            print("Reauthentication error")
            return false
        }
        
    }
    
    func verifyUserProvider(provider: String) -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false // No user is logged in
        }
        
        // Loop through the user's providerData to check if the user is authenticated with the given provider
        for userInfo in user.providerData {
            if userInfo.providerID == provider {
                return true
            }
        }
        
        return false
    }
    
    private func mapFirebaseAuthError(_ error: NSError) -> String {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return "An unknown error occurred. Please try again."
        }
        
        switch errorCode {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "This email is already in use. Please log in instead."
        case .weakPassword:
            return "The password is too weak. Please use at least 6 characters."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
}


