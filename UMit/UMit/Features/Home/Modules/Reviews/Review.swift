import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var reviewerName: String
    var comment: String
    var rating: Double
    var doctorId: String?
    var hospitalId: String?
    var createdAt: Date
}
