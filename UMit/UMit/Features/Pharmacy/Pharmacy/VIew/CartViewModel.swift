import Foundation
import SwiftUI
import FirebaseFirestore

class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var totalPoints: Int = 0
    
    private let db = Firestore.firestore()
    private let itemsKey = "cartItems"
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([CartItem].self, from: data) {
            DispatchQueue.main.async {
                self.items = decodedItems
                self.updateTotalPoints()
            }
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    func addToCart(medicine: Medicine, quantity: Int = 1) {
        guard let medicineId = medicine.id else { return }
        
        DispatchQueue.main.async {
            if let index = self.items.firstIndex(where: { $0.medicineId == medicineId }) {
                self.items[index].quantity += quantity
            } else {
                let newItem = CartItem(
                    id: UUID().uuidString,
                    medicineId: medicineId,
                    medicineName: medicine.name,
                    imageURL: medicine.imageURL,
                    points: medicine.points,
                    quantity: quantity
                )
                self.items.append(newItem)
            }
            self.updateTotalPoints()
            self.saveItems()
        }
    }
    
    func removeFromCart(medicineId: String) {
        DispatchQueue.main.async {
            self.items.removeAll { $0.medicineId == medicineId }
            self.updateTotalPoints()
            self.saveItems()
        }
    }
    
    func updateQuantity(medicineId: String, quantity: Int) {
        DispatchQueue.main.async {
            if let index = self.items.firstIndex(where: { $0.medicineId == medicineId }) {
                if quantity > 0 {
                    self.items[index].quantity = quantity
                } else {
                    self.items.remove(at: index)
                }
            }
            self.updateTotalPoints()
            self.saveItems()
        }
    }
    
    private func updateTotalPoints() {
        totalPoints = items.reduce(0) { $0 + $1.totalPoints }
    }
    
    func clearCart() {
        DispatchQueue.main.async {
            self.items.removeAll()
            self.updateTotalPoints()
            self.saveItems()
        }
    }
    
    func createOrder(userId: String, completion: @escaping (Error?) -> Void) {
        let orderItems = items.map { item in
            MedicineOrder.OrderItem(
                medicineId: item.medicineId,
                medicineName: item.medicineName,
                imageURL: item.imageURL,
                points: item.points,
                quantity: item.quantity
            )
        }
        
        let order = MedicineOrder(
            id: UUID().uuidString,
            userId: userId,
            items: orderItems,
            totalPoints: totalPoints,
            timestamp: Date()
        )
        
        let data: [String: Any] = [
            "id": order.id,
            "userId": order.userId,
            "items": orderItems.map { [
                "medicineId": $0.medicineId,
                "medicineName": $0.medicineName,
                "imageURL": $0.imageURL,
                "points": $0.points,
                "quantity": $0.quantity
            ]},
            "totalPoints": order.totalPoints,
            "timestamp": Timestamp(date: order.timestamp)
        ]
        
        db.collection("orders").document(order.id).setData(data) { error in
            if error == nil {
                self.clearCart()
            }
            completion(error)
        }
    }
} 