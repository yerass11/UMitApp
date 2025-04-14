import SwiftUI

struct PharmacyView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var pharmacyVM = PharmacyViewModel()
    @StateObject private var paymentVM = PaymentViewModel()

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
                                        .multilineTextAlignment(.leading)
                                    Text(med.description)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        OrderHistoryView()
                            .environmentObject(viewModel)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                pharmacyVM.fetchMedicines()
            }
            .alert("Confirm Order", isPresented: $showConfirmation) {
                Button("Confirm") {
                    guard let med = selectedMedicine,
                          let userId = viewModel.user?.uid else { return }

                    // 1. Запрашиваем client_secret у backend, передавая цену
                    paymentVM.fetchPaymentIntent(amount: med.points * 100) { success in
                        if success {
                            // 2. Показываем Stripe PaymentSheet
                            paymentVM.presentPaymentSheet { result in
                                switch result {
                                case .completed:
                                    // 3. После успешной оплаты — создаём заказ
                                    pharmacyVM.placeOrder(medicine: med, userId: userId) { error in
                                        if let error = error {
                                            print("❌ Error placing order:", error.localizedDescription)
                                        } else {
                                            print("✅ Order placed")
                                        }
                                    }
                                case .canceled:
                                    print("⚠️ Payment canceled")
                                case .failed(let error):
                                    print("❌ Payment failed:", error.localizedDescription)
                                }
                            }
                        } else {
                            print("❌ Failed to prepare Stripe Payment")
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
