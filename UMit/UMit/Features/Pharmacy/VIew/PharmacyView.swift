import SwiftUI

struct PharmacyView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var pharmacyVM = PharmacyViewModel()

    @State private var selectedMedicine: Medicine?
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(pharmacyVM.medicines) { med in
                        Button {
                            selectedMedicine = med
                            showConfirmation = true
                        } label: {
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
                                    Text(med.description)
                                        .font(.subheadline)
                                        .frame(alignment: .leading)
                                        .foregroundColor(.gray)
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
                }
                .padding()
            }
            .navigationTitle("Pharmacy")
            .onAppear {
                pharmacyVM.fetchMedicines()
            }
            .alert("Confirm Order", isPresented: $showConfirmation) {
                Button("Confirm") {
                    if let med = selectedMedicine,
                       let userId = viewModel.user?.uid {
                        pharmacyVM.placeOrder(medicine: med, userId: userId) { error in
                            if let error = error {
                                print("❌ Error placing order:", error.localizedDescription)
                            } else {
                                print("✅ Order placed")
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let med = selectedMedicine {
                    Text("Redeem \(med.points) points for \(med.name)?")
                }
            }
        }
    }
}
