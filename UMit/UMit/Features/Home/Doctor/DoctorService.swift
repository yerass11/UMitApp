import FirebaseFirestore

struct Doctor: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var specialty: String
    var experience: Int
    var clinic: String
    var imageURL: String?
    var rating: Double? 
}

final class DoctorService {
    static let shared = DoctorService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchDoctors(completion: @escaping ([Doctor]) -> Void) {
        db.collection("doctors").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching doctors: \(error)")
                completion([])
                return
            }

            let doctors = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Doctor.self)
            } ?? []
            completion(doctors)
        }
    }
}
