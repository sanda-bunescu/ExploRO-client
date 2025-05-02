import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
@preconcurrency import FBSDKLoginKit
import Foundation

enum FirebaseErrorCode: Error {
    case invalidEmail
    case invalidPassword
    case invalidUser
    case invalidCredentials
    case invalidToken
    case invalidTokenType
    case invalidTokenExpiration
    case invalidTokenSignature
    case invalidTokenPayload
    case internalError
    case reauthenticationFailed
    case processInterrupted
}

protocol FirebaseAuthenticationProtocol {
    func loginWithEmailAndPassword(with email: String, password: String) async throws -> User
    func registerWithEmailAndPassword(with email: String, password: String) async throws -> User
    func logout() throws
    func deleteUser() async throws
    func reauthenticateUserWithEmailAndPassword(with email: String, password: String) async throws -> User
    func loginWithGoogle() async throws -> User
    func reauthenticateUserWithGoogle() async throws -> User
    func loginWithFacebook() async throws -> User
    func reauthenticateUserWithFacebook() async throws -> User
    func sendPasswordReset(to email: String) async throws
}

class FirebaseAuthentication: FirebaseAuthenticationProtocol {
    
    
    func loginWithEmailAndPassword(with email: String, password: String) async throws -> User{
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user
        
    }
    func registerWithEmailAndPassword(with email: String, password: String) async throws -> User{
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        print("I am hereeee: registerWithEmailAndPassword")
        return authResult.user
    }
    func logout() throws{
        try Auth.auth().signOut()
    }
    func deleteUser() async throws{
        guard let user = Auth.auth().currentUser else{
            print("No user is signed in.")
            return
        }
        do{
            try await user.delete()
        }catch{
            
        }
    }
    func reauthenticateUserWithEmailAndPassword(with email: String, password: String) async throws -> User{
        guard let user = Auth.auth().currentUser else {
            throw FirebaseErrorCode.invalidUser
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
            return user
        } catch {
            throw FirebaseErrorCode.reauthenticationFailed
        }
    }
    func loginWithGoogle() async throws -> User{
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw FirebaseErrorCode.invalidCredentials}
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Find the root view controller to present Google Sign-In
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller.")
            throw FirebaseErrorCode.internalError
        }
        
        // Start the sign in flow!
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { userAuthentication, error in
                    if let error = error {
                        print("Google Sign-In failed: \(error.localizedDescription)")
                        continuation.resume(throwing: FirebaseErrorCode.internalError)
                        return
                    }
                    
                    guard let fetchedUser = userAuthentication?.user,
                          let idToken = fetchedUser.idToken?.tokenString else {
                        print("Unable to get user or ID token.")
                        continuation.resume(throwing: FirebaseErrorCode.internalError)
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: fetchedUser.accessToken.tokenString
                    )
                    
                    Task {
                        do {
                            let result = try await Auth.auth().signIn(with: credential)
                            continuation.resume(returning: result.user)
                        } catch {
                            print("Firebase login with Google failed: \(error.localizedDescription)")
                            continuation.resume(throwing: FirebaseErrorCode.internalError)
                        }
                    }
                }
            }
        }
    }
    func reauthenticateUserWithGoogle() async throws -> User{
        guard let user = Auth.auth().currentUser else {
            throw FirebaseErrorCode.invalidUser
        }
        do{
            guard let credential = try await getGooleAccessToken()else{
                throw FirebaseErrorCode.invalidCredentials
            }
            try await user.reauthenticate(with: credential)
            return user
            
        }catch{
            print("Error getting Google Access Token: \(error.localizedDescription)")
            throw FirebaseErrorCode.internalError
        }
    }
    
    func loginWithFacebook() async throws -> User {
        let loginManager = LoginManager()
        
        guard let windowScene = await  UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            throw FirebaseErrorCode.internalError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                loginManager.logIn(permissions: ["public_profile", "email"], from: rootViewController) { result, error in
                    if let error = error {
                        print("Facebook login failed: \(error.localizedDescription)")
                        continuation.resume(throwing: FirebaseErrorCode.invalidToken)
                        return
                    }
                    
                    guard let result = result, !result.isCancelled else {
                        print("User cancelled Facebook login.")
                        continuation.resume(throwing: FirebaseErrorCode.processInterrupted)
                        return
                    }
                    
                    guard let accessToken = AccessToken.current?.tokenString else {
                        print("Unable to get Facebook access token.")
                        continuation.resume(throwing: FirebaseErrorCode.invalidToken)
                        return
                    }
                    
                    // Facebook access token to authenticate with Firebase
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                    
                    Task {
                        do {
                            // Authenticate with Firebase using the Facebook credential
                            let authResult = try await Auth.auth().signIn(with: credential)
                            continuation.resume(returning: authResult.user)
                        } catch {
                            print("Firebase login with Facebook failed: \(error.localizedDescription)")
                            continuation.resume(throwing: FirebaseErrorCode.reauthenticationFailed)
                        }
                    }
                }
            }
        }
    }
    
    
    func reauthenticateUserWithFacebook() async throws -> User {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseErrorCode.invalidUser
        }
        
        guard let credential = try await getFacebookAccessToken()else{
            throw FirebaseErrorCode.invalidCredentials
        }
        
        do {
            try await user.reauthenticate(with: credential)
            return user
        } catch {
            print("Reauthentication failed: \(error.localizedDescription)")
            throw FirebaseErrorCode.invalidCredentials
        }
        
    }
    
    private func getGooleAccessToken() async throws -> AuthCredential?{
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller.")
            throw FirebaseErrorCode.internalError
        }
        do{
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let fetchedUser = userAuthentication.user
            guard let idToken = fetchedUser.idToken?.tokenString else {
                print("Unable to get user or ID token.")
                throw FirebaseErrorCode.internalError
            }
            
            return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: fetchedUser.accessToken.tokenString)
        }catch{
            throw FirebaseErrorCode.internalError
        }
    }
    
    private func getFacebookAccessToken() async throws -> AuthCredential? {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller.")
            throw FirebaseErrorCode.internalError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let loginManager = LoginManager()
            
            // Initiate Facebook login to force reauthentication
            loginManager.logIn(permissions: ["public_profile", "email"], from: rootViewController) { result, error in
                if let error = error {
                    print("Facebook login failed: \(error.localizedDescription)")
                    continuation.resume(throwing: FirebaseErrorCode.internalError)
                    return
                }
                
                guard let result = result, !result.isCancelled,
                      let accessToken = AccessToken.current?.tokenString else {
                    print("User cancelled Facebook login or no access token available.")
                    continuation.resume(throwing: FirebaseErrorCode.processInterrupted)
                    return
                }
                //return credentials
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                continuation.resume(returning: credential)
            }
        }
    }
    
    func sendPasswordReset(to email: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
