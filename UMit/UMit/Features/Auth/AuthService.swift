import Foundation
import FirebaseAuth

final class AuthService {
    static let shared = AuthService()  // Синглтон для единой точки доступа
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                return
            }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        }
    }

    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
