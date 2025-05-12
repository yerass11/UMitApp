import Foundation
import FirebaseFirestore

class HospitalService {
    private let db = Firestore.firestore()

    func fetchHospitals(completion: @escaping ([Hospital]) -> Void) {
        db.collection("hospitals").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Ошибка загрузки больниц: \(error?.localizedDescription ?? "неизвестно")")
                completion([])
                return
            }

            let hospitals = documents.compactMap { doc -> Hospital? in
                try? doc.data(as: Hospital.self)
            }
            completion(hospitals)
        }
    }
}
