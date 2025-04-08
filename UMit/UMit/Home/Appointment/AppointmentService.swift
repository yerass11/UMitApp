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

        db.collection("appointments").addDocument(data: data, completion: completion)
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
