import Foundation
import FirebaseAuth

final class AuthService {
    static let shared = AuthService()
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
                    self.sendUserToBackend(uid: user.uid, email: email, fullName: fullName)
                    completion(.success(user))
                }
            }
        }
    }
    
    private func sendUserToBackend(uid: String, email: String, fullName: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/register_firebase_user/") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let payload: [String: String] = [
                "uid": uid,
                "email": email,
                "full_name": fullName
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

            URLSession.shared.dataTask(with: request).resume()
        }

    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
