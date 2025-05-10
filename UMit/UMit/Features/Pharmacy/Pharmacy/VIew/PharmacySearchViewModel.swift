import SwiftUI
import Combine

class PharmacySearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: MedicineCategory?
    @Published var priceRange: ClosedRange<Double> = 0...1000
    @Published var showOnlyAvailable = false
    @Published var showOnlyNonPrescription = false
    @Published var sortOption: SortOption = .nameAsc
    
    @Published var medicines: [Medicine] = []
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption: String, CaseIterable {
        case nameAsc = "Name (A-Z)"
        case nameDesc = "Name (Z-A)"
        case priceAsc = "Price (Low to High)"
        case priceDesc = "Price (High to Low)"
    }
    
    var filteredMedicines: [Medicine] {
        var filtered = medicines
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        filtered = filtered.filter { Double($0.points) >= priceRange.lowerBound && Double($0.points) <= priceRange.upperBound }
        
        if showOnlyAvailable {
            filtered = filtered.filter { $0.isAvailable ?? true }
        }
        
        // Apply prescription filter
        if showOnlyNonPrescription {
            filtered = filtered.filter { !($0.isPrescriptionRequired ?? false) }
        }
        
        switch sortOption {
        case .nameAsc:
            filtered.sort { $0.name < $1.name }
        case .nameDesc:
            filtered.sort { $0.name > $1.name }
        case .priceAsc:
            filtered.sort { $0.points < $1.points }
        case .priceDesc:
            filtered.sort { $0.points > $1.points }
        }
        
        return filtered
    }
    
    func resetFilters() {
        selectedCategory = nil
        priceRange = 0...1000
        showOnlyAvailable = false
        showOnlyNonPrescription = false
        sortOption = .nameAsc
    }
} 
