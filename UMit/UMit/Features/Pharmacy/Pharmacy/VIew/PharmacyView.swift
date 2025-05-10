import SwiftUI

struct PharmacyView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var pharmacyVM = PharmacyViewModel()

    @State private var selectedMedicine: Medicine?
    @State private var showDetail = false
    @State private var showSearch = false
    @State private var showOrders = false

    @Binding var showTab: Bool

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(pharmacyVM.medicines) { med in
                            MedicineRow(med: med)
                                .onTapGesture {
                                    selectedMedicine = med
                                    showDetail = true
                                }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }

                if let selectedMedicine = selectedMedicine {
                    NavigationLink(destination: detailView(for: selectedMedicine),
                                   isActive: $showDetail) {
                        EmptyView()
                    }
                    .hidden()
                }

                NavigationLink(destination: OrderHistoryView().environmentObject(viewModel),
                               isActive: $showOrders) {
                    EmptyView()
                }
                .hidden()

                NavigationLink(destination: PharmacySearchView(viewModel: viewModel, showTab: $showTab),
                               isActive: $showSearch) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("Pharmacy")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showOrders = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }
            }
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
                pharmacyVM.fetchMedicines()
            }
        }
    }

    private func detailView(for med: Medicine) -> some View {
        if let uid = viewModel.user?.uid {
            return AnyView(
                PharmacyMedicineDetailSheetView(medicine: med, userId: uid) {
                    pharmacyVM.fetchMedicines()
                }
            )
        } else {
            return AnyView(ProgressView().foregroundColor(.accent))
        }
    }
}

struct MedicineRow: View {
    let med: Medicine

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: med.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(med.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(med.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }

            Spacer()

            Text("\(med.points) $")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
