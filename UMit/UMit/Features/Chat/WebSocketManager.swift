import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    var onMessageReceived: ((ChatMessage) -> Void)?
    
    func connect(room: String, senderId: String, token: String) {
        let urlString = "wss://backend-production-d019d.up.railway.app/ws/chat/\(room)/?token=\(senderId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("✅ WebSocket connected to \(url)")
        listen()
    }
    
    func sendMessage(message: ChatMessage, receiverId: String) {
        let payload: [String: Any] = [
            "message": message.content,
            "sender_id": message.senderId,
            "receiver_id": receiverId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to encode message as JSON string")
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ Send error: \(error)")
            } else {
                print("✅ Message sent")
            }
        }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleIncoming(data: data)
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        self?.handleIncoming(data: data)
                    }
                @unknown default:
                    print("❌ Unknown message format")
                }
                self?.listen()
            case .failure(let error):
                print("❌ Receive error: \(error)")
            }
        }
    }
    
    private func handleIncoming(data: Data) {
        do {
            let message = try JSONDecoder().decode(ChatMessage.self, from: data)
            DispatchQueue.main.async {
                self.onMessageReceived?(message)
            }
        } catch {
            print("❌ Failed to decode message: \(error)")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("❌ WebSocket disconnected")
    }
}
