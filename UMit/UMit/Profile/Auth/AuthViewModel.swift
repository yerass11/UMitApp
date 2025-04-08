import Foundation
import FirebaseAuth
import Combine

final class AuthViewModel: ObservableObject {
    @Published var user: User?         // Храним авторизованного пользователя
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // Вход в систему
    func signIn(email: String, password: String) {
        isLoading = true
        AuthService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Регистрация нового пользователя
    func signUp(email: String, password: String, fullName: String) {
        isLoading = true
        AuthService.shared.signUp(email: email, password: password, fullName: fullName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Выход из системы
    func signOut() {
        do {
            try AuthService.shared.signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
