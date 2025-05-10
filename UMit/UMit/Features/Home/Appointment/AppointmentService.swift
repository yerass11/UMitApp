import FirebaseFirestore

final class AppointmentService {
    static let shared = AppointmentService()
    private init() {}

    private let db = Firestore.firestore()

    func createAppointment(userId: String, doctor: Doctor, date: Date, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "userId": userId,
            "doctorId": doctor.id ?? "",
            "doctorName": doctor.fullName,
            "timestamp": Timestamp(date: date)
        ]

        let collection = db.collection("appointments")
        var ref: DocumentReference? = nil
        
        
        ref = collection.addDocument(data: data) { error in
            if let error = error {
                print("❌ Error adding document: \(error.localizedDescription)")
                completion(error)
            } else if let documentId = ref?.documentID {
                print("📄 New appointment ID: \(documentId)")
                completion(nil)
                let url = URL(string: "http://127.0.0.1:8000/api/sessions/")!

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let isoDate = ISO8601DateFormatter().string(from: date)

                let json: [String: Any] = [
                    "client_id": userId,
                    "medics_id": doctor.id ?? "",
                    "appointment": isoDate,
                    "fid": String(documentId)
                ]

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                    request.httpBody = jsonData
                } catch {
                    completion(error)
                    return
                }

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                        completion(err)
                        return
                    }

                    completion(nil)
                }.resume()
            }
        }
    }
    
    func fetchAppointments(for userId: String, completion: @escaping ([Appointment]) -> Void) {
        db.collection("appointments")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching appointments: \(error)")
                    completion([])
                    return
                }

                let appointments = snapshot?.documents.compactMap { doc -> Appointment? in
                    let data = doc.data()
                    guard
                        let doctorName = data["doctorName"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp,
                        let doctorId = data["doctorId"] as? String
                    else { return nil }

                    return Appointment(
                        id: doc.documentID,
                        userId: userId,
                        doctorId: doctorId,
                        doctorName: doctorName,
                        timestamp: timestamp.dateValue()
                    )
                } ?? []

                completion(appointments)
            }
    }
}
