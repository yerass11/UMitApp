import Foundation

struct ChatGroup: Identifiable, Codable {
    let id: Int
    let doctor: ChatDoctor
}
