import Foundation

class DocumentViewModel: ObservableObject {
    @Published var documents: [Document] = []

    func fetchDocuments(for userID: String) {
        guard let url = URL(string: "https://backend-production-d019d.up.railway.app/api/documents/\(userID)/") else { return }

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
