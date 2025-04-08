import SwiftUI

struct AccountTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var phoneNumber: String = ""
    @State private var gender: String = ""
    @State private var birthDate: Date = Date()
    @State private var showDatePicker = false
    @State private var showLogoutConfirm = false

    let genders = ["Male", "Female"]

    var fullName: String {
        viewModel.user?.displayName ?? "Not set"
    }

    var email: String {
        viewModel.user?.email ?? "-"
    }

    var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 10) {
                    Image("profile_photo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .shadow(radius: 3)

                    Text(fullName)
                        .font(.title3.bold())

                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Editable fields
                VStack(spacing: 16) {
                    EditableField(title: "Phone Number", text: $phoneNumber, placeholder: "+7 707 ...")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gender")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Picker("Gender", selection: $gender) {
                            Text("Not set").tag("")
                            ForEach(genders, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date of Birth")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Text(formattedBirthDate)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }

                        if showDatePicker {
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                    }
                }

                // Save & Sign Out
                VStack(spacing: 12) {
                    Button(action: {
                        print("✅ Saved: \(phoneNumber), \(gender), \(birthDate)")
                        // Здесь можно вызвать UserService.shared.saveUserProfile()
                    }) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.red)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .padding(.bottom, 100) // чтобы кнопка не пряталась за TabBar
        }
        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showLogoutConfirm) {
            Button("Sign Out", role: .destructive) {
                viewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
