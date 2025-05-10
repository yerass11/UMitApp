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
    
    func fetchFavoriteDoctors(userID: String, completion: @escaping ([Doctor]) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error fetching favorite doctors: \(error)")
                completion([])
                return
            }

            if let favoriteDoctorRefs = document?.data()?["favoriteDoctors"] as? [DocumentReference] {
                print("Favorite doctors found: \(favoriteDoctorRefs.count)") // Логируем количество врачей в избранном
                self.fetchDoctorsDetails(favoriteDoctorRefs: favoriteDoctorRefs, completion: completion)
            } else {
                print("No favoriteDoctors field found for user \(userID)")
                completion([]) // Если поле не существует, возвращаем пустой массив
            }
        }
    }

    private func fetchDoctorsDetails(favoriteDoctorRefs: [DocumentReference], completion: @escaping ([Doctor]) -> Void) {
        var doctors: [Doctor] = []

        for doctorRef in favoriteDoctorRefs {
            doctorRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching doctor: \(error)")
                    completion([])
                    return
                }

                if let document = document, document.exists {
                    if let doctor = try? document.data(as: Doctor.self) {
                        doctors.append(doctor)
                    }
                }

                // Логируем количество загруженных врачей
                print("Doctors loaded so far: \(doctors.count) / \(favoriteDoctorRefs.count)")

                // Если все врачи загружены, вызываем completion
                if doctors.count == favoriteDoctorRefs.count {
                    completion(doctors)
                }
            }
        }
    }
    
    func addDoctorToFavorites(userID: String, doctorID: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(userID)
        let doctorReference = db.collection("doctors").document(doctorID)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot

            do {
                userDocument = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                print("Error fetching user document: \(fetchError)")
                completion(false)
                return nil
            }

            // Получаем массив favoriteDoctors или создаем новый массив, если его нет
            var favoriteDoctors = userDocument.data()?["favoriteDoctors"] as? [DocumentReference] ?? []

            // Добавляем doctorReference в массив, если его еще нет
            if !favoriteDoctors.contains(doctorReference) {
                favoriteDoctors.append(doctorReference)
                transaction.updateData(["favoriteDoctors": favoriteDoctors], forDocument: userRef)
            }

            return nil
        }) { (_, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(false)
            } else {
                print("Doctor added to favorites!")
                completion(true)
            }
        }
    }
    func removeDoctorFromFavorites(userID: String, doctorID: String, completion: @escaping (Bool) -> Void) {
            let doctorReference = db.collection("doctors").document(doctorID)

            db.collection("users").document(userID).updateData([
                "favoriteDoctors": FieldValue.arrayRemove([doctorReference])
            ]) { error in
                if let error = error {
                    print("Error removing doctor from favorites: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Doctor removed from favorites!")
                    completion(true)
                }
            }
        }
    func checkIfDoctorIsFavorite(userID: String, doctorID: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error checking if doctor is favorite: \(error)")
                completion(false)
                return
            }

            // Проверяем наличие массива favoriteDoctors
            if let favoriteDoctorRefs = document?.data()?["favoriteDoctors"] as? [DocumentReference] {
                let isFavorite = favoriteDoctorRefs.contains { doctorRef in
                    doctorRef.documentID == doctorID
                }
                completion(isFavorite)
            } else {
                print("No favoriteDoctors field found for user \(userID)")
                completion(false)
            }
        }
    }
}
