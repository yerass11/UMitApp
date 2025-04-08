import SwiftUI
import FirebaseAuth

struct PasswordTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isUpdating = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)

                    Text("Change your password")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    SecureInputField(title: "Current Password", text: $currentPassword)
                    SecureInputField(title: "New Password", text: $newPassword)
                    SecureInputField(title: "Confirm Password", text: $confirmPassword)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: handleChangePassword) {
                    if isUpdating {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(isUpdating)

                Spacer()
            }
            .padding()
            .padding(.bottom, 100)
        }
    }

    private func handleChangePassword() {
        errorMessage = nil
        successMessage = nil

        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard let user = viewModel.user, let email = user.email else {
            errorMessage = "User not found."
            return
        }

        isUpdating = true

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                isUpdating = false
                self.errorMessage = "Re-authentication failed: \(error.localizedDescription)"
                return
            }

            user.updatePassword(to: newPassword) { error in
                isUpdating = false
                if let error = error {
                    self.errorMessage = "Password update failed: \(error.localizedDescription)"
                } else {
                    self.successMessage = "Password updated successfully."
                    self.currentPassword = ""
                    self.newPassword = ""
                    self.confirmPassword = ""
                }
            }
        }
    }
}
