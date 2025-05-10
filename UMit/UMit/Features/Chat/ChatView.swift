import SwiftUI
import FirebaseAuth

struct ChatView: View {
    let doctor: ChatDoctor
    let userId: String  // Firebase UID

    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @StateObject private var socketManager = WebSocketManager()
    @State private var groupId: Int?

    var roomId: String {
        [userId, doctor.doctorFirebaseID].sorted().joined(separator: "_")
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.senderId == userId {
                                    Spacer()
                                    Text(msg.content)
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(msg.content)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                            .id(msg.id) // 👈 добавь идентификатор
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    // Автоматическая прокрутка вниз
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Скролл при загрузке
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let lastMessage = messages.last {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding(.bottom, 70)
            .padding()
        }
        .navigationTitle("\(doctor.fullName)")
        .onAppear {
            fetchOrCreateChatGroup()
            Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print("Ошибка получения токена: \(error.localizedDescription)")
                    return
                }

                if let token = idToken {
                    print("🔥 Firebase ID Token: \(token)")
                    socketManager.connect(room: roomId, senderId: userId, token: token)
                }
            }
            

            socketManager.onMessageReceived = { message in
                print("📩 Received:", message.content)
                messages.append(message)
            }
        }
        .onDisappear {
            socketManager.disconnect()
        }
    }

    func sendMessage() {
        guard let groupId = groupId else {
            print("groupId is nil, message not sent")
            return
        }

        let message = ChatMessage(
            id: UUID().uuidString,
            senderId: String(userId),
            content: messageText,
            timestamp: Date()
        )

        socketManager.sendMessage(message: message, receiverId: doctor.doctorFirebaseID ?? "")
//        messages.append(message)
        messageText = ""

        ChatService.saveMessage(roomId: groupId, message: message)
    }

    func fetchOrCreateChatGroup() {
        let doctorId = doctor.doctorFirebaseID
        let urlString = "http://127.0.0.1:8000/api/chat/group/\(userId)/\(doctorId)/"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let groupId = json["id"] as? Int {
                DispatchQueue.main.async {
                    self.groupId = groupId
                    self.loadMessages()
                }
            } else {
                print("Ошибка при получении чата")
            }
        }.resume()
    }

    func loadMessages() {
        guard let groupId = groupId else { return }

        let urlString = "http://127.0.0.1:8000/api/messages/group/\(groupId)/"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.messages = jsonArray.compactMap { dict in
                            guard let senderId = dict["sender_id"] as? String,
                                  let content = dict["content"] as? String
                            else {
                                return nil
                            }

                            let id = String(dict["id"] as? Int ?? UUID().hashValue)

                            var timestamp: Date? = nil
                            if let timestampStr = dict["timestamp"] as? String {
                                timestamp = ISO8601DateFormatter().date(from: timestampStr)
                            }

                            return ChatMessage(id: id, senderId: senderId, content: content, timestamp: timestamp ?? Date())
                        }
                    }
                }
            }
        }.resume()
    }
}

