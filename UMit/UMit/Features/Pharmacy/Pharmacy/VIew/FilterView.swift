import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: PharmacySearchViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Category Section
                Section(header: Text("Category")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(MedicineCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: {
                                        if viewModel.selectedCategory == category {
                                            viewModel.selectedCategory = nil
                                        } else {
                                            viewModel.selectedCategory = category
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Price Range Section
                Section(header: Text("Price Range")) {
                    VStack {
                        HStack {
                            Text("$\(Int(viewModel.priceRange.lowerBound))")
                            Spacer()
                            Text("$\(Int(viewModel.priceRange.upperBound))")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.priceRange.lowerBound },
                                set: { viewModel.priceRange = $0...viewModel.priceRange.upperBound }
                            ),
                            in: 0...1000,
                            step: 10
                        )
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.priceRange.upperBound },
                                set: { viewModel.priceRange = viewModel.priceRange.lowerBound...$0 }
                            ),
                            in: 0...1000,
                            step: 10
                        )
                    }
                }
                
                // Availability Section
                Section(header: Text("Availability")) {
                    Toggle("Show Only Available", isOn: $viewModel.showOnlyAvailable)
                }
                
                // Prescription Section
                Section(header: Text("Prescription")) {
                    Toggle("Show Only Non-Prescription", isOn: $viewModel.showOnlyNonPrescription)
                }
                
                // Sort Section
                Section(header: Text("Sort By")) {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(PharmacySearchViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                // Reset Button
                Section {
                    Button("Reset Filters") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: MedicineCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
} 