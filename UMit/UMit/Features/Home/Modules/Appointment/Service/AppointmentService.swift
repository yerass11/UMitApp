import Foundation
import FirebaseFirestore

final class AppointmentService {
    static let shared = AppointmentService()
    private init() {}

    private let db = Firestore.firestore()

    func createAppointment(
        userId: String,
        doctor: Doctor,
        date: Date,
        completion: @escaping (Error?) -> Void
    ) {
        let collection = db.collection("appointments")
        let ts = Timestamp(date: date)
        let did = doctor.id ?? ""

        collection
            .whereField("doctorId", isEqualTo: did)
            .whereField("timestamp", isEqualTo: ts)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async { completion(error) }
                    return
                }
                if let docs = snapshot?.documents, !docs.isEmpty {
                    let err = NSError(
                        domain: "",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Этот слот уже забронирован"]
                    )
                    DispatchQueue.main.async { completion(err) }
                    return
                }

                let data: [String: Any] = [
                    "userId": userId,
                    "doctorId": did,
                    "doctorName": doctor.fullName,
                    "timestamp": ts
                ]

                var ref: DocumentReference?
                ref = collection.addDocument(data: data) { error in
                    if let error = error {
                        DispatchQueue.main.async { completion(error) }
                        return
                    }
                    guard let documentId = ref?.documentID else {
                        let err = NSError(
                            domain: "",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Неизвестная ошибка"]
                        )
                        DispatchQueue.main.async { completion(err) }
                        return
                    }

                    let url = URL(string: "https://backend-production-d019d.up.railway.app/api/sessions/")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let isoDate = ISO8601DateFormatter().string(from: date)
                    let json: [String: Any] = [
                        "client_id": userId,
                        "medics_id": did,
                        "appointment": isoDate,
                        "fid": documentId
                    ]

                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: json)
                    } catch {
                        DispatchQueue.main.async { completion(error) }
                        return
                    }

                    URLSession.shared.dataTask(with: request) { _, response, error in
                        if let error = error {
                            DispatchQueue.main.async { completion(error) }
                            return
                        }
                        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                            let err = NSError(
                                domain: "",
                                code: http.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Server error \(http.statusCode)"]
                            )
                            DispatchQueue.main.async { completion(err) }
                        } else {
                            DispatchQueue.main.async { completion(nil) }
                        }
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
                let list = snapshot?.documents.compactMap { doc -> Appointment? in
                    let d = doc.data()
                    guard
                        let doctorName = d["doctorName"] as? String,
                        let ts = d["timestamp"] as? Timestamp,
                        let doctorId = d["doctorId"] as? String
                    else { return nil }
                    return Appointment(
                        id: doc.documentID,
                        userId: userId,
                        doctorId: doctorId,
                        doctorName: doctorName,
                        timestamp: ts.dateValue()
                    )
                } ?? []
                completion(list)
            }
    }
}
