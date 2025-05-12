import SwiftUI

enum PaymentResult {
    case completed
    case canceled
    case failed(Error)
}

struct PaymentView: View {
    let amount: Int
    let onCompletion: (PaymentResult) -> Void
    
    @StateObject private var paymentVM = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Payment Details")
                    .font(.title2)
                    .bold()
                
                Text("Amount: $\(amount / 100)")
                    .font(.headline)
                
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Button {
                    isProcessing = true
                    paymentVM.fetchPaymentIntent(amount: amount) { success in
                        if success {
                            paymentVM.presentPaymentSheet { stripeResult in
                                isProcessing = false
                                let result: PaymentResult
                                switch stripeResult {
                                case .completed:
                                    result = .completed
                                case .canceled:
                                    result = .canceled
                                case .failed(let error):
                                    result = .failed(error)
                                }
                                onCompletion(result)
                                dismiss()
                            }
                        } else {
                            isProcessing = false
                            onCompletion(.failed(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare payment"])))
                            dismiss()
                        }
                    }
                } label: {
                    Text("Proceed to Payment")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isProcessing)
                .padding(.horizontal)
                
                Button("Cancel") {
                    onCompletion(.canceled)
                    dismiss()
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onCompletion(.canceled)
                        dismiss()
                    }
                }
            }
        }
    }
} 