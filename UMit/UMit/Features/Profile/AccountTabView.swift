import SwiftUI
import FirebaseFirestore

struct AccountTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var fullName = ""
    @State private var phone = ""
    @State private var gender = "Man"
    @State private var birthDate = Date()

    var body: some View {
        Form {
            Section(header: Text("Personal Info")) {
                TextField("Full Name", text: $fullName)
                TextField("Phone Number", text: $phone)
                    .keyboardType(.phonePad)
                    .onChange(of: phone) { newValue in
                            phone = newValue.filter { "0123456789".contains($0) }
                        }

                Picker("Gender", selection: $gender) {
                    Text("Man").tag("Man")
                    Text("Woman").tag("Woman")
                }

                DatePicker("Date of Birth", selection: $birthDate, displayedComponents: [.date])
            }

            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                .foregroundColor(.blue)
            }

            Section {
                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        fullName = viewModel.user?.displayName ?? ""
    }

    private func saveChanges() {
        guard let user = viewModel.user else { return }
        let uid = user.uid
        let db = Firestore.firestore()

        db.collection("users").document(uid).setData([
            "fullName": fullName,
            "phone": phone,
            "gender": gender,
            "birthDate": Timestamp(date: birthDate)
        ], merge: true) { error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
            } else {
                print("✅ Saved!")
            }
        }
    }
}
