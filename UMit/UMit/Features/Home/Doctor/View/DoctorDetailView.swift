import SwiftUI
import FirebaseAuth

struct DoctorDetailView: View {
    let doctor: Doctor

    @EnvironmentObject var viewModel: AuthViewModel

    @State private var reservationSuccess = false
    @State private var reservationError: String?
    @State private var selectedDate = Date()
    @StateObject var reviewViewModel = ReviewViewModel()
    @State private var showReviewForm = false

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

                DatePicker("Appointment Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
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
        }
        .padding(.horizontal)
        .navigationTitle("Doctor")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $reservationSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You successfully reserved an appointment with \(doctor.fullName).")
        }
    }

    // MARK: - Appointment Logic

    private func reserveAppointment() {
        guard let userId = viewModel.user?.uid else {
            reservationError = "You must be logged in to reserve."
            return
        }

        AppointmentService.shared.createAppointment(
            userId: userId,
            doctor: doctor,
            date: selectedDate
        ) { error in
            if let error = error {
                reservationError = error.localizedDescription
            } else {
                reservationSuccess = true
                reservationError = nil
            }
        }
    }
}
