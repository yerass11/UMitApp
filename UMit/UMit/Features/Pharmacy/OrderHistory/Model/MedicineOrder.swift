import SwiftUI

struct MedicineOrder: Identifiable {
    var id: String
    var userId: String
    var medicineName: String
    var imageURL: String
    var points: Int
    var quantity: Int
    var timestamp: Date
}
