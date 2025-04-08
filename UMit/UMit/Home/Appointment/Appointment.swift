import Foundation

struct Appointment: Identifiable {
    var id: String
    var userId: String
    var doctorId: String
    var doctorName: String
    var timestamp: Date
}
