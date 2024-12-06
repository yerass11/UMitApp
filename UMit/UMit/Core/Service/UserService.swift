import FirebaseAuth
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    
    private init() {}

    private let db = Firestore.firestore()

    func saveUserProfile(
        uid: String,
        phoneNumber: String,
        gender: String,
        birthDate: Date,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "phoneNumber": phoneNumber,
            "gender": gender,
            "birthDate": Timestamp(date: birthDate)
        ]

        db.collection("users").document(uid).setData(data, merge: true, completion: completion)
    }

    func fetchUserProfile(uid: String, completion: @escaping (_ data: [String: Any]?, _ error: Error?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(snapshot?.data(), nil)
        }
    }
}
