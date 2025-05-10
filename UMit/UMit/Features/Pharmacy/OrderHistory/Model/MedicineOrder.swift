import SwiftUI

struct MedicineOrder: Identifiable {
    var id: String
    var userId: String
    var items: [OrderItem]
    var totalPoints: Int
    var timestamp: Date
    
    struct OrderItem: Codable {
        var medicineId: String
        var medicineName: String
        var imageURL: String
        var points: Int
        var quantity: Int
        
        var totalPoints: Int {
            points * quantity
        }
    }
    
    var medicineName: String {
        items.map { "\($0.medicineName) x\($0.quantity)" }.joined(separator: ", ")
    }
    
    var imageURL: String {
        items.first?.imageURL ?? ""
    }
    
    var points: Int {
        totalPoints
    }
    
    var quantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
