import SwiftUI
import Combine

struct PharmacySearchView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var searchVM = PharmacySearchViewModel()
    @StateObject private var pharmacyVM = PharmacyViewModel()
    @State private var showFilters = false
    @State private var selectedMedicine: Medicine?
    @State private var showDetail = false
    
    @Binding var showTab: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search medicines...", text: $searchVM.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchVM.searchText.isEmpty {
                        Button(action: {
                            searchVM.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Active Filters
                if searchVM.selectedCategory != nil || searchVM.showOnlyAvailable || searchVM.showOnlyNonPrescription {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if let category = searchVM.selectedCategory {
                                FilterChip(text: category.rawValue) {
                                    searchVM.selectedCategory = nil
                                }
                            }
                            if searchVM.showOnlyAvailable {
                                FilterChip(text: "Available Only") {
                                    searchVM.showOnlyAvailable = false
                                }
                            }
                            if searchVM.showOnlyNonPrescription {
                                FilterChip(text: "Non-Prescription Only") {
                                    searchVM.showOnlyNonPrescription = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // Results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if searchVM.filteredMedicines.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                Text("No medicines found")
                                    .font(.headline)
                                Text("Try adjusting your search or filters")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(searchVM.filteredMedicines) { medicine in
                                NavigationLink(destination: detailView(for: medicine)) {
                                    MedicineCard(medicine: medicine)
                                        .padding(.horizontal, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Search Medicines")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: searchVM)
            }
            .onAppear {
                showTab = false
                pharmacyVM.fetchMedicines()
            }
            .onChange(of: pharmacyVM.medicines) { newMedicines in
                searchVM.medicines = newMedicines
            }
        }
    }
    
    private func detailView(for medicine: Medicine) -> some View {
        if let userId = viewModel.user?.uid {
            return AnyView(
                PharmacyMedicineDetailSheetView(medicine: medicine, userId: userId) {
                    pharmacyVM.fetchMedicines()
                }
            )
        } else {
            return AnyView(ProgressView().foregroundColor(.accent))
        }
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}
