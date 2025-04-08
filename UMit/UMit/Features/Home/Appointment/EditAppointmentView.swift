import SwiftUI
import FirebaseFirestore

struct EditAppointmentView: View {
    @Environment(\.dismiss) var dismiss

    var appointment: Appointment
    var onSave: () -> Void

    let timeSlots: [Int] = [10, 11, 12, 14, 15, 16, 17]

    @State private var selectedDate: Date
    @State private var selectedHour: Int? = nil
    @State private var bookedHours: [Int] = []

    init(appointment: Appointment, onSave: @escaping () -> Void) {
        self.appointment = appointment
        self.onSave = onSave
        _selectedDate = State(initialValue: appointment.timestamp)
        _selectedHour = State(initialValue: Calendar.current.component(.hour, from: appointment.timestamp))
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("New Date")) {
                        DatePicker("Select Date",
                                   selection: $selectedDate,
                                   in: Date()...,
                                   displayedComponents: [.date])
                            .onChange(of: selectedDate) { _ in
                                fetchBookedSlots()
                            }
                    }
                }
                .frame(height: 150)

                Text("Select Time Slot")
                    .font(.headline)
                    .padding(.top)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(timeSlots, id: \.self) { hour in
                        let isBooked = bookedHours.contains(hour)
                        let isSelected = selectedHour == hour

                        Button {
                            if !isBooked {
                                selectedHour = hour
                            }
                        } label: {
                            Text("\(hour):00")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isBooked ? Color.gray.opacity(0.3)
                                                     : isSelected ? Color.blue : Color.white)
                                .foregroundColor(isBooked ? .gray : isSelected ? .white : .black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(isBooked)
                    }
                }
                .padding()

                Spacer()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    Spacer()
                    Button("Save") {
                        updateAppointment()
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Edit Appointment")
            .onAppear {
                fetchBookedSlots()
            }
        }
    }

    private func updateAppointment() {
        guard let hour = selectedHour else { return }

        let calendar = Calendar.current
        guard let dateWithHour = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) else {
            return
        }

        let docRef = Firestore.firestore().collection("appointments").document(appointment.id)
        docRef.updateData([
            "timestamp": Timestamp(date: dateWithHour)
        ]) { error in
            if let error = error {
                print("❌ Error updating: \(error.localizedDescription)")
            } else {
                print("✅ Appointment updated!")
                onSave()
                dismiss()
            }
        }
    }

    private func fetchBookedSlots() {
        Firestore.firestore().collection("appointments")
            .whereField("doctorId", isEqualTo: appointment.doctorId)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                let calendar = Calendar.current
                let booked = docs.compactMap { doc -> Int? in
                    guard let timestamp = doc["timestamp"] as? Timestamp else { return nil }
                    let date = timestamp.dateValue()
                    return calendar.isDate(date, inSameDayAs: selectedDate)
                           ? calendar.component(.hour, from: date)
                           : nil
                }
                self.bookedHours = booked
                print("📆 selectedDate:", selectedDate)
                print("⛔️ bookedHours:", booked)
            }
    }
}
