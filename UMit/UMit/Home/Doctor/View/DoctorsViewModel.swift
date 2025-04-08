import SwiftUI

final class DoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []

    init() {
        fetchDoctors()
    }

    func fetchDoctors() {
        DoctorService.shared.fetchDoctors { [weak self] result in
            DispatchQueue.main.async {
                self?.doctors = result
            }
        }
    }
}
