import Foundation

class DocumentViewModel: ObservableObject {
    @Published var documents: [Document] = []

    func fetchDocuments(for userID: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/documents/\(userID)/") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Document].self, from: data)
                    DispatchQueue.main.async {
                        self.documents = decoded
                    }
                } catch {
                    print("Decoding error:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
}
