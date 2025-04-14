import FirebaseFirestore

final class MedicineOrderService {
    static let shared = MedicineOrderService()
    private let db = Firestore.firestore()

    func fetchOrders(for userId: String, completion: @escaping ([MedicineOrder]) -> Void) {
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    print("❌ Error fetching orders:", error?.localizedDescription ?? "Unknown error")
                    completion([])
                    return
                }

                let orders = docs.compactMap { doc -> MedicineOrder? in
                    let data = doc.data()
                    guard let name = data["medicineName"] as? String,
                          let imageURL = data["imageURL"] as? String,
                          let points = data["points"] as? Int,
                          let ts = data["timestamp"] as? Timestamp
                    else { return nil }

                    print("📡 Fetching orders for:", userId)

                    return MedicineOrder(
                        id: doc.documentID,
                        userId: userId,
                        medicineName: name,
                        imageURL: imageURL,
                        points: points,
                        timestamp: ts.dateValue()
                    )
                }

                completion(orders)
            }
    }
}
