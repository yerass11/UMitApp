import Foundation
import FirebaseFirestore

struct Hospital: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var address: String
    var phone: String
    var rating: Double
    var imageURL: String?
}

