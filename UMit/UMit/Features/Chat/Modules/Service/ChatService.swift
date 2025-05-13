import Foundation

class ChatService {
    static func fetchChats(for userId: String) async throws -> [ChatGroup] {
        guard let url = URL(string: "https://backend-production-d019d.up.railway.app/api/chats/\(userId)/") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([ChatGroup].self, from: data)
    }

    static func saveMessage(roomId: Int, message: ChatMessage) async throws {
        guard let url = URL(string: "https://backend-production-d019d.up.railway.app/api/chat/save/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(message)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
}


