import SwiftUI

struct PharmacyMedicineDetailSheetView: View {
    let medicine: Medicine
    let userId: String
    let onOrderSuccess: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var quantity: Int = 1
    @State private var isProcessing = false
    @StateObject private var paymentVM = PaymentViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: medicine.imageURL)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()

                    Text(medicine.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 10)

                    Text(medicine.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack(spacing: 20) {
                            Button(action: {
                                if quantity > 1 { quantity -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(quantity > 1 ? .accent : .gray)
                            }
                            .disabled(quantity == 1)

                            Text("\(quantity)")
                                .font(.title2)
                                .frame(width: 50)
                                .foregroundColor(.primary)

                            Button(action: {
                                if quantity < 10 { quantity += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(quantity < 10 ? .accent : .gray)
                            }
                            .disabled(quantity == 10)
                        }
                        .padding(8)
                        .background(Color(.white))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                        )
                    }

                    Text("Total: \(medicine.points * quantity) $")
                        .font(.headline)
                        .foregroundColor(.accent)
                        .padding(.top, 10)

                    Button {
                        isProcessing = true
                        paymentVM.fetchPaymentIntent(amount: medicine.points * quantity * 100) { success in
                            if success {
                                paymentVM.presentPaymentSheet { result in
                                    switch result {
                                    case .completed:
                                        PharmacyViewModel().placeOrder(medicine: medicine, userId: userId, quantity: quantity) { error in
                                            isProcessing = false
                                            if error == nil {
                                                onOrderSuccess()
                                                dismiss()
                                            }
                                        }
                                    case .canceled:
                                        print("⚠️ Payment canceled")
                                        isProcessing = false
                                    case .failed(let error):
                                        print("❌ Payment failed:", error.localizedDescription)
                                        isProcessing = false
                                    }
                                }
                            } else {
                                print("❌ Failed to prepare Stripe payment")
                                isProcessing = false
                            }
                        }
                    } label: {
                        Text(isProcessing ? "Processing..." : "Buy Now")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isProcessing ? Color.gray : Color.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(isProcessing)
                    }
                    .disabled(isProcessing)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 150)
                .navigationTitle("Medicine Details")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
