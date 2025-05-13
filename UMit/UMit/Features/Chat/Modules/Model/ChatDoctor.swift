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
