import SwiftUI
import FirebaseFirestore

struct AccountTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var fullName = ""
    @State private var phone = ""
    @State private var gender = "Man"
    @State private var birthDate = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""

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
        }
        .onAppear {
            loadData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Changes Saved"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func loadData() {
        guard let user = viewModel.user else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                fullName = document.data()?["fullName"] as? String ?? ""
                phone = document.data()?["phone"] as? String ?? ""
                gender = document.data()?["gender"] as? String ?? "Man"
                if let timestamp = document.data()?["birthDate"] as? Timestamp {
                    birthDate = timestamp.dateValue()
                }
            } else {
                print("❌ Error loading data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
                alertMessage = "Failed to save changes: \(error.localizedDescription)"
                showAlert = true
            } else {
                print("✅ Saved!")
                alertMessage = "Your changes have been saved successfully."
                showAlert = true
            }
        }
    }
}
