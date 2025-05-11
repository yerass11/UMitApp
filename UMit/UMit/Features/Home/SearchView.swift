import SwiftUI
import Combine

struct SearchView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var doctorVM = DoctorsViewModel()
    @StateObject private var hospitalVM = HospitalsViewModel()

    @State private var searchText = ""
    @State private var selectedTab: SearchTab = .doctors
    @State private var debounceTimer: AnyCancellable?
    
    @Binding var showTab: Bool

    enum SearchTab: String, CaseIterable {
        case doctors = "Doctors"
        case hospitals = "Hospitals"
    }

    var body: some View {
        VStack {
            Picker("Search Category", selection: $selectedTab) {
                ForEach(SearchTab.allCases, id: \ .self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search...", text: $searchText)
                    .onChange(of: searchText) { _ in debounceSearch() }
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 12) {
                    if selectedTab == .doctors {
                        let results = filteredDoctors
                        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ForEach(doctorVM.doctors.sorted { ($0.rating ?? 0, $0.fullName) > ($1.rating ?? 0, $1.fullName) }) { doctor in
                                DoctorCard(doctor: doctor, viewModel: viewModel, showTab: $showTab)
                                    .padding(.horizontal, 8)
                            }
                        } else if results.isEmpty {
                            Text("No doctors found matching your query.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(results) { doctor in
                                DoctorCard(doctor: doctor, viewModel: viewModel, showTab: $showTab)
                                    .padding(.horizontal, 8)
                            }
                        }
                    } else {
                        let results = filteredHospitals
                        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ForEach(hospitalVM.hospitals.sorted { ($0.rating, $0.name) > ($1.rating, $1.name) }) { hospital in
                                HospitalCard(hospital: hospital, viewModel: viewModel)
                                    .padding(.horizontal, 8)
                            }
                        } else if results.isEmpty {
                            Text("No hospitals found matching your query.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(results) { hospital in
                                HospitalCard(hospital: hospital, viewModel: viewModel)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            doctorVM.fetchDoctors()
            hospitalVM.fetchHospitals()
            showTab = false
        }
    }

    private func debounceSearch() {
        debounceTimer?.cancel()
        debounceTimer = Just(searchText)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { _ in }
    }

    private var filteredDoctors: [Doctor] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return doctorVM.doctors
            .filter {
                $0.fullName.lowercased().contains(trimmed) ||
                $0.specialty.lowercased().contains(trimmed) ||
                $0.clinic.lowercased().contains(trimmed)
            }
            .sorted {
                let lhsRating = $0.rating ?? 0
                let rhsRating = $1.rating ?? 0
                if lhsRating == rhsRating {
                    return $0.fullName < $1.fullName
                }
                return lhsRating > rhsRating
            }
    }

    private var filteredHospitals: [Hospital] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return hospitalVM.hospitals
            .filter {
                $0.name.lowercased().contains(trimmed) ||
                $0.address.lowercased().contains(trimmed)
            }
            .sorted {
                if $0.rating == $1.rating {
                    return $0.name < $1.name
                }
                return $0.rating > $1.rating
            }
    }
}
