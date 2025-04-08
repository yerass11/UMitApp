import FirebaseFirestore

final class PharmacyViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []

    private let db = Firestore.firestore()

    func placeOrder(medicine: Medicine, userId: String, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "userId": userId,
            "medicineId": medicine.id,
            "medicineName": medicine.name,
            "timestamp": Timestamp(date: Date()),
            "points": medicine.points
        ]

        db.collection("orders").addDocument(data: data, completion: completion)
    }
    
    func fetchMedicines() {
        db.collection("medicines").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore error:", error.localizedDescription)
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No documents")
                return
            }

            let meds = documents.compactMap { doc in
                try? doc.data(as: Medicine.self)
            }

            print("📦 Fetched medicines:", meds.count)
            self.medicines = meds
        }
    }
}
