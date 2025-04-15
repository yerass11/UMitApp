import SwiftUI
import Combine

struct PharmacySearchView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var pharmacyVM = PharmacyViewModel()

    @State private var searchText = ""
    @State private var debounceTimer: AnyCancellable?
    
    @Binding var showTab: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search medicines...", text: $searchText)
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
                    let results = filteredMedicines
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ForEach(pharmacyVM.medicines.sorted { $0.name < $1.name }) { med in
                            MedicineCard(medicine: med)
                                .padding(.horizontal, 8)
                        }
                    } else if results.isEmpty {
                        Text("No medicines found matching your query.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(results) { med in
                            MedicineCard(medicine: med)
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .navigationTitle("Search Medicines")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pharmacyVM.fetchMedicines()
            showTab = false
        }
    }

    private func debounceSearch() {
        debounceTimer?.cancel()
        debounceTimer = Just(searchText)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { _ in }
    }

    private var filteredMedicines: [Medicine] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return pharmacyVM.medicines
            .filter {
                $0.name.lowercased().contains(trimmed) ||
                $0.description.lowercased().contains(trimmed)
            }
            .sorted {
                let lhsScore = $0.name.lowercased().contains(trimmed) ? 1 : 0
                let rhsScore = $1.name.lowercased().contains(trimmed) ? 1 : 0
                if lhsScore == rhsScore {
                    return $0.points < $1.points
                }
                return lhsScore > rhsScore
            }
    }
}
