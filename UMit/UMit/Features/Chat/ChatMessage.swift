import Foundation

struct ChatMessage: Identifiable, Codable {
    var id: String?
    var senderId: String
    var content: String
    let timestamp: Date?
    
    enum CodingKeys: String, CodingKey {
            case id
            case senderId = "sender_id"
            case content
            case timestamp
    }
}
