import Foundation

struct ChatMessage: Identifiable, Codable {
    var id: String
    var senderId: String
    var content: String
    let timestamp: Date
}
