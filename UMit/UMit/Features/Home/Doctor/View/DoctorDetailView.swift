import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DoctorDetailView: View {
    let doctor: Doctor

    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showTab: Bool

    @State private var reservationSuccess = false
    @State private var reservationError: String?
    @State private var showReviewForm = false
    @State private var selectedDate = Date()
    @State private var selectedHour: Int? = nil
    @State private var bookedHours: [Int] = []
    @StateObject var reviewViewModel = ReviewViewModel()

    var body: some View {
        VStack(spacing: 24) {
            AsyncImage(url: URL(string: doctor.imageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .shadow(radius: 5)
            .padding(.top, 40)

            // Информация о враче
            VStack(spacing: 6) {
                Text(doctor.fullName)
                    .font(.title2.weight(.bold))

                Text(doctor.specialty)
                    .foregroundColor(.secondary)

                Text("Experience: \(doctor.experience) years")
                    .font(.subheadline)

                Text("Clinic: \(doctor.clinic)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            VStack {
                ReviewsSectionView(viewModel: reviewViewModel)

                Button("Оставить отзыв") {
                    showReviewForm = true
                }
                .sheet(isPresented: $showReviewForm) {
                    ReviewFormView(doctorId: doctor.id)
                }
            }
            .onAppear {
                print("Fetching reviews for doctorId: \(doctor.id)")
                reviewViewModel.fetchReviews(forDoctorId: doctor.id)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                    Text("Select Date & Time")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date])
                        .onChange(of: selectedDate) { _ in
                            fetchBookedSlots()
                        }
                        .labelsHidden()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach([10, 11, 12, 14, 15, 16, 17], id: \.self) { hour in
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
            }
            .padding(.horizontal)

            Spacer()

            Button {
                reserveAppointment()
            } label: {
                Text("Reserve Appointment")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.bottom, 24)
            .padding(.horizontal)

            if let error = reservationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }
            
            NavigationLink(destination: ChatView(doctor: ChatDoctor(id: 1, doctorFirebaseID: doctor.id!, fullName: doctor.fullName, specialty: doctor.specialty, imageURL: doctor.imageURL), userId: viewModel.user?.uid ?? "")) {
                Text("Chat with Doctor")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .navigationTitle("Doctor")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $reservationSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You successfully reserved an appointment with \(doctor.fullName).")
        }
        .onAppear{
            showTab = false
        }
    }

    // MARK: - Appointment Logic

    private func reserveAppointment() {
        guard let userId = viewModel.user?.uid else {
            reservationError = "You must be logged in to reserve."
            return
        }

        guard let hour = selectedHour else {
            reservationError = "Please select a time slot."
            return
        }

        let calendar = Calendar.current
        guard let dateWithHour = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) else {
            reservationError = "Invalid time selected."
            return
        }

        AppointmentService.shared.createAppointment(
            userId: userId,
            doctor: doctor,
            date: dateWithHour
        ) { error in
            if let error = error {
                reservationError = error.localizedDescription
            } else {
                reservationSuccess = true
                reservationError = nil
            }
        }
    }

    private func fetchBookedSlots() {
        guard let doctorId = doctor.id else { return }

        Firestore.firestore().collection("appointments")
            .whereField("doctorId", isEqualTo: doctorId)
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
            }
    }
}
