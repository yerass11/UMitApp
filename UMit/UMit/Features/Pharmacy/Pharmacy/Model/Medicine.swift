import Foundation
import FirebaseFirestore

struct Medicine: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String
    var description: String
    var points: Int
    var imageURL: String
}
