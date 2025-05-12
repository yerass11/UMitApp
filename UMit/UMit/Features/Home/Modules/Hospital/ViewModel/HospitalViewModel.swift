import Foundation
import FirebaseFirestore

class HospitalsViewModel: ObservableObject {
    @Published var hospitals: [Hospital] = []

    private var db = Firestore.firestore()

    init() {
        fetchHospitals()
    }

    func fetchHospitals() {
        db.collection("hospitals").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading hospitals: \(error.localizedDescription)")
                return
            }

            self.hospitals = snapshot?.documents.compactMap { document in
                try? document.data(as: Hospital.self)
            } ?? []
        }
        print("Fetched hospitals: \(self.hospitals)")

    }
}
