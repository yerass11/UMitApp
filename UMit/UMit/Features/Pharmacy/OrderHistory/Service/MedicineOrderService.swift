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
                    
                    // Handle both old and new order formats
                    if let items = data["items"] as? [[String: Any]] {
                        // New format with multiple items
                        let orderItems = items.compactMap { itemData -> MedicineOrder.OrderItem? in
                            guard let medicineId = itemData["medicineId"] as? String,
                                  let medicineName = itemData["medicineName"] as? String,
                                  let imageURL = itemData["imageURL"] as? String,
                                  let points = itemData["points"] as? Int,
                                  let quantity = itemData["quantity"] as? Int
                            else { return nil }
                            
                            return MedicineOrder.OrderItem(
                                medicineId: medicineId,
                                medicineName: medicineName,
                                imageURL: imageURL,
                                points: points,
                                quantity: quantity
                            )
                        }
                        
                        guard let totalPoints = data["totalPoints"] as? Int,
                              let ts = data["timestamp"] as? Timestamp
                        else { return nil }
                        
                        return MedicineOrder(
                            id: doc.documentID,
                            userId: userId,
                            items: orderItems,
                            totalPoints: totalPoints,
                            timestamp: ts.dateValue()
                        )
                    } else {
                        // Old format with single item
                        guard let name = data["medicineName"] as? String,
                              let imageURL = data["imageURL"] as? String,
                              let points = data["points"] as? Int,
                              let quantity = data["quantity"] as? Int,
                              let ts = data["timestamp"] as? Timestamp
                        else { return nil }
                        
                        let item = MedicineOrder.OrderItem(
                            medicineId: data["medicineId"] as? String ?? UUID().uuidString,
                            medicineName: name,
                            imageURL: imageURL,
                            points: points,
                            quantity: quantity
                        )
                        
                        return MedicineOrder(
                            id: doc.documentID,
                            userId: userId,
                            items: [item],
                            totalPoints: points * quantity,
                            timestamp: ts.dateValue()
                        )
                    }
                }

                completion(orders)
            }
    }
}
