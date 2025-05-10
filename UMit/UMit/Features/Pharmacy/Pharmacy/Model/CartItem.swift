import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let medicineId: String
    let medicineName: String
    let imageURL: String
    let points: Int
    var quantity: Int
    
    var totalPoints: Int {
        return points * quantity
    }
} 