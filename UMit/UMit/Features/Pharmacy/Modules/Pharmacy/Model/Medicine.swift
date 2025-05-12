import Foundation
import FirebaseFirestore

struct Medicine: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var name: String
    var description: String
    var points: Int
    var imageURL: String
    var category: MedicineCategory?
    var isPrescriptionRequired: Bool?
    var isAvailable: Bool?
    
    static func == (lhs: Medicine, rhs: Medicine) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.points == rhs.points &&
        lhs.imageURL == rhs.imageURL &&
        lhs.category == rhs.category &&
        lhs.isPrescriptionRequired == rhs.isPrescriptionRequired &&
        lhs.isAvailable == rhs.isAvailable
    }
}

enum MedicineCategory: String, Codable, CaseIterable, Equatable {
    case painRelief = "Pain Relief"
    case antibiotics = "Antibiotics"
    case vitamins = "Vitamins"
    case firstAid = "First Aid"
    case skincare = "Skincare"
    case other = "Other"
}
