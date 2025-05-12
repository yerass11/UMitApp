import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var documentViewModel = DocumentViewModel()
    @StateObject private var doctorsViewModel = DoctorsViewModel()
    @StateObject private var hospitalsViewModel = HospitalsViewModel()

    @FocusState private var isSearchFocused: Bool
    @State private var showAllDoctors = false
    @State private var showAllDocuments = false
    @State private var showAllHospitals = false
    @State private var userAppointments: [Appointment] = []
    @State private var appointmentToEdit: Appointment?
    @State private var showEditSheet = false
    @State private var searchText: String = ""
    @State private var showSearchMode: Bool = false
    @State private var selectedTab: SearchTab = .doctors
    @State private var showSearchScreen: Bool = false

    @Binding var showTab: Bool

    var fullName: String? { viewModel.user?.displayName }

    enum SearchTab: String, CaseIterable {
        case doctors = "Doctors"
        case clinics = "Clinics"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if showSearchMode {
                        searchTabs
                        filteredSearchResults
                    } else {
                        upcomingAppointments
                        documentsSection
                        clinicSection
                        hospitalSection
                    }
                }
                .padding(.bottom, 100)
                .animation(.easeInOut, value: showSearchMode)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearchScreen = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationTitle(Text("Hello, \(fullName ?? "User")"))
            .background(
                NavigationLink("", destination: SearchView(viewModel: viewModel, showTab: $showTab), isActive: $showSearchScreen)
                    .opacity(0)
            )
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y
            }, action: { oldValue, newValue in
                if newValue > oldValue {
                    withAnimation {
                        showTab = false
                    }
                } else if newValue < oldValue + 10 {
                    showTab = true
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
    }

    var searchTabs: some View {
        Picker("Search Category", selection: $selectedTab) {
            ForEach(SearchTab.allCases, id: \ .self) { tab in
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
                    DoctorCard(doctor: doctor, viewModel: viewModel, showTab: $showTab)
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
        return doctorsViewModel.doctors.filter {
            $0.fullName.lowercased().contains(searchText.lowercased()) ||
            $0.specialty.lowercased().contains(searchText.lowercased()) ||
            $0.clinic.lowercased().contains(searchText.lowercased())
        }
    }

    var upcomingAppointments: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal, 8)
            
            let upcoming = userAppointments.filter { $0.timestamp >= Date() }
            
            if upcoming.isEmpty {
                VStack(spacing: 12) {
                    Text("You have no appointments yet")
                        .foregroundColor(.gray)
                    Button("Book Now") {
                        showAllDoctors = true
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(upcoming) { appointment in
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
    var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Available Documents")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    showAllDocuments = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Show all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accent)
                }
            }
            .padding(.horizontal, 6)

            ForEach(documentViewModel.documents.prefix(2)) { document in
                VStack(alignment: .leading, spacing: 8) {
                    Text(document.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Uploaded at \(document.formattedDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let url = URL(string: document.downloadURL) {
                        Link("View Document", destination: url)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
            }
        }
        .onAppear {
            guard let userId = viewModel.user?.uid else {
                print("❌ userId is nil")
                return
            }
            documentViewModel.fetchDocuments(for: userId)
        }
        .sheet(isPresented: $showAllDocuments) {
            DocumentsListView(viewModel: documentViewModel)
        }
    }

    var clinicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Doctors")
                    .font(.title3.bold())
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                        showAllDoctors = true
                }, label: {
                    HStack(spacing: 4) {
                        Text("Show all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accent)
                })
            }
            .padding(.horizontal, 8)

            ForEach(doctorsViewModel.doctors.prefix(2)) { doctor in
                DoctorCard(doctor: doctor, viewModel: viewModel, showTab: $showTab)
                    .padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showAllDoctors) {
            DoctorsListView(authViewModel: viewModel, showTab: $showTab)
        }
    }

    var hospitalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Hospitals")
                    .font(.title2.bold())
                    .foregroundColor(.black)

                Spacer()
                
                Button(action: {
                    showAllHospitals = true
                }, label: {
                    HStack(spacing: 4) {
                        Text("Show all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accent)
                })
            }
            .padding(.horizontal, 8)

            ForEach(hospitalsViewModel.hospitals.prefix(2)) { hospital in
                HospitalCard(hospital: hospital, viewModel: viewModel)
                    .padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showAllHospitals) {
            HospitalsListView()
        }
    }

    private func fetchAppointments() {
        guard let userId = viewModel.user?.uid else {
            print("❌ userId is nil")
            return
        }

        AppointmentService.shared.fetchAppointments(for: userId) { appointments in
            DispatchQueue.main.async {
                print("✅ Appointments fetched:", appointments.count)
                self.userAppointments = appointments
            }
        }
    }

    private func deleteAppointment(_ appointment: Appointment) {
        Firestore.firestore().collection("appointments").document(appointment.id).delete { error in
            if let error = error {
                print("❌ Failed to delete: \(error.localizedDescription)")
            } else {
                guard let url = URL(string: "https://backend-production-d019d.up.railway.app/api/sessions/\(appointment.id)/") else {
                    print("❌ Invalid URL")
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("❌ Failed to delete: \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Invalid response")
                        return
                    }

                    if httpResponse.statusCode == 204 {
                        DispatchQueue.main.async {
                            fetchAppointments()
                        }
                    } else {
                        print("❌ Failed with status code: \(httpResponse.statusCode)")
                    }
                }.resume()
                fetchAppointments()
            }
        }
    }
}
