import Foundation

struct ChatDoctor: Identifiable, Codable {
    let id: Int
    let doctorFirebaseID: String
    let fullName: String
    let specialty: String
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case doctorFirebaseID = "doctor_firebase_id"
        case fullName = "medic_name"
        case specialty = "speciality"
        case imageURL = "medic_image"
    }
}

struct ChatGroup: Identifiable, Codable {
    let id: Int
    let doctor: ChatDoctor
}


class ChatService {
    static func fetchChats(for userId: String, completion: @escaping ([ChatGroup]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/chats/\(userId)/") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([ChatGroup].self, from: data) {
                    DispatchQueue.main.async {
                        completion(decoded)
                    }
                }
            }
        }.resume()
    }

    static func saveMessage(roomId: Int, message: ChatMessage) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/chat/save/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "group": roomId,
            "sender_id": message.senderId,
            "content": message.content,
            "timestamp": ""
        ]
    }
}

