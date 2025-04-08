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
            Form {
                Section(header: Text("New Date")) {
                    DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date])
                        .onChange(of: selectedDate) { _ in
                            fetchBookedSlots()
                        }
                }
                
                Section(header: Text("Select Time Slot")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 12) {
                        ForEach(timeSlots, id: \.self) { hour in
                            let isBooked = bookedHours.contains(hour)
                            let isSelected = selectedHour == hour
                            
                            Button(action: {
                                if !isBooked {
                                    selectedHour = hour
                                }
                            }) {
                                Text("\(hour):00")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isBooked ? Color.gray.opacity(0.3) :
                                                    isSelected ? Color.blue : Color.white)
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
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Appointment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateAppointment()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchBookedSlots()
            }
        }
    }
    
    private func updateAppointment() {
        guard let hour = selectedHour else { return }
        
        let calendar = Calendar.current
        let dateWithHour = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate)!
        
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

                let sameDay = { (d1: Date, d2: Date) in
                    calendar.isDate(d1, inSameDayAs: d2)
                }

                let booked = docs.compactMap { doc -> Int? in
                    guard let timestamp = doc["timestamp"] as? Timestamp else { return nil }
                    let date = timestamp.dateValue()
                    return sameDay(date, selectedDate) ? calendar.component(.hour, from: date) : nil
                }

                self.bookedHours = booked
                print("📆 selectedDate:", selectedDate)
                print("⛔️ bookedHours:", booked)
            }
    }
}
