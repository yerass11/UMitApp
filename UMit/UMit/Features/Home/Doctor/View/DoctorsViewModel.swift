import SwiftUI

final class DoctorsViewModel: ObservableObject {
    @StateObject var viewModel = AuthViewModel()
    @Published var doctors: [Doctor] = []
    @Published var favoriteDoctors: [Doctor] = []
    private var userId: String = ""

    init() {
        self.userId = viewModel.userID!
        fetchDoctors()
        fetchFavoriteDoctors()
    }

    func fetchDoctors() {
        DoctorService.shared.fetchDoctors { [weak self] result in
            DispatchQueue.main.async {
                self?.doctors = result
            }
        }
    }
    func fetchFavoriteDoctors() {
        DoctorService.shared.fetchFavoriteDoctors(userID: userId) { [weak self] result in
            DispatchQueue.main.async {
                print("Favorite doctors loaded: \(result.count)")
                self?.favoriteDoctors = result
            }
        }
    }
    func addDoctorToFavorites(doctorID: String) {
           DoctorService.shared.addDoctorToFavorites(userID: userId, doctorID: doctorID) { [weak self] success in
               if success {
                   self?.fetchFavoriteDoctors()
               }
           }
       }
    func removeDoctorFromFavorites(doctorID: String) {
           DoctorService.shared.removeDoctorFromFavorites(userID: userId, doctorID: doctorID) { [weak self] success in
               if success {
                   self?.fetchFavoriteDoctors()
               }
           }
       }
}
