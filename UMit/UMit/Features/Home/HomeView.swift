import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var doctorVM = DoctorsViewModel()
    
    @State private var showAllDoctors = false
    @State private var userAppointments: [Appointment] = []
    @State private var appointmentToEdit: Appointment?
    @State private var showEditSheet = false

    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showSearchMode: Bool = false
    @State private var selectedTab: SearchTab = .doctors

    @Binding var showTab: Bool
    
    var fullName: String? { viewModel.user?.displayName }
    var address: String = "Islam Karima 70"

    enum SearchTab: String, CaseIterable {
        case doctors = "Doctors"
        case clinics = "Clinics"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                header
                addressInfo
                searchBar

                if showSearchMode {
                    searchTabs
                    filteredSearchResults
                } else {
                    servicesInfo
                    upcomingAppointments
                    clinicSection
                    pharmacySection
                }
            }
            .animation(.easeInOut, value: showSearchMode)
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.contentOffset.y
        }, action: { oldValue, newValue in
            withAnimation {
                showTab = newValue < oldValue + 10
            }
        })
        .onAppear {
            fetchAppointments()
        }
        .sheet(item: $appointmentToEdit) { appointment in
            EditAppointmentView(appointment: appointment) {
                fetchAppointments()
            }
        }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hello,")
                    .font(.system(size: 20, weight: .regular))
                if let name = fullName {
                    Text(name)
                        .font(.system(size: 24, weight: .semibold))
                }
            }
            Spacer()
            Image("profile_photo")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(.circle)
        }
        .padding(.top, 50)
        .padding(.horizontal, 8)
    }

    var addressInfo: some View {
        HStack {
            Image(systemName: "location.north.fill")
                .frame(width: 20, height: 20)
                .foregroundStyle(.blue)
            
            Text(address)
                .font(.system(size: 11, weight: .semibold))
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    var searchBar: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(height: 50)
                    .foregroundStyle(.gray.opacity(0.3))
                
                HStack {
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search in UMit", text: $searchText, onEditingChanged: { editing in
                        withAnimation {
                            showSearchMode = editing || !searchText.isEmpty
                        }
                    })
                    .focused($isSearchFocused)
                    .textFieldStyle(PlainTextFieldStyle())

                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            withAnimation {
                                showSearchMode = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 8)
        .onChange(of: showSearchMode) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isSearchFocused = true
                }
            }
        }
    }

    var searchTabs: some View {
        Picker("Search Category", selection: $selectedTab) {
            ForEach(SearchTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }

    var filteredSearchResults: some View {
        Group {
            if selectedTab == .doctors {
                ForEach(filteredDoctors) { doctor in
                    DoctorCard(doctor: doctor, viewModel: viewModel)
                        .padding(.horizontal, 8)
                }
            } else {
                Text("Clinics search coming soon...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    var filteredDoctors: [Doctor] {
        if searchText.isEmpty { return [] }
        return doctorVM.doctors.filter {
            $0.fullName.lowercased().contains(searchText.lowercased()) ||
            $0.specialty.lowercased().contains(searchText.lowercased()) ||
            $0.clinic.lowercased().contains(searchText.lowercased())
        }
    }

    var servicesInfo: some View {
        HStack(alignment: .top, spacing: 20) {
            ServiceButton(icon: "person.fill", color: .blue, backgroundColor: Color(.systemBlue).opacity(0.2), title: "Clinic Reservation")
            ServiceButton(icon: "pill.fill", color: .red, backgroundColor: Color(.systemRed).opacity(0.2), title: "Redeem Medicine")
            ServiceButton(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2), title: "Test Covid 19")
            ServiceButton(icon: "doc.text.fill", color: .orange, backgroundColor: Color(.systemOrange).opacity(0.2), title: "Recipes")
        }
        .padding()
    }

    var upcomingAppointments: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal, 8)

            if userAppointments.isEmpty {
                VStack(spacing: 12) {
                    Text("You have no appointments yet")
                        .foregroundColor(.gray)
                    Button("Book Now") {
                        showAllDoctors = true
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(userAppointments) { appointment in
                    AppointmentCardView(
                        appointment: appointment,
                        onDelete: { deleteAppointment(appointment) },
                        onEdit: {
                            appointmentToEdit = appointment
                            showEditSheet = true
                        }
                    )
                    .padding(.horizontal, 8)
                }
            }
        }
    }

    var clinicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Doctors")
                    .font(.title2.bold())
                
                Spacer()
                
                Button("See All") {
                    showAllDoctors = true
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 8)

            ForEach(doctorVM.doctors.prefix(2)) { doctor in
                DoctorCard(doctor: doctor, viewModel: viewModel)
                    .padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showAllDoctors) {
            DoctorsListView()
        }
    }

    var pharmacySection: some View {
        ServiceSection(title: "Pharmacy Services", services: [
            Service(icon: "person.fill", color: .blue, backgroundColor: Color(.systemBlue).opacity(0.2)),
            Service(icon: "pill.fill", color: .red, backgroundColor: Color(.systemRed).opacity(0.2)),
            Service(icon: "doc.text.fill", color: .orange, backgroundColor: Color(.systemOrange).opacity(0.2)),
            Service(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2)),
        ])
    }

    private func fetchAppointments() {
        guard let userId = viewModel.user?.uid else {
            print("❌ userId is nil")
            return
        }

        AppointmentService.shared.fetchAppointments(for: userId) { appointments in
            DispatchQueue.main.async {
                self.userAppointments = appointments
            }
        }
    }

    private func deleteAppointment(_ appointment: Appointment) {
        Firestore.firestore().collection("appointments").document(appointment.id).delete { error in
            if let error = error {
                print("❌ Failed to delete: \(error.localizedDescription)")
            } else {
                fetchAppointments()
            }
        }
    }
}
