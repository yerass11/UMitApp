import SwiftUI

struct PharmacyMedicineDetailSheetView: View {
    let medicine: Medicine
    let userId: String
    let onOrderSuccess: () -> Void

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cartVM: CartViewModel
    @State private var quantity: Int = 1
    @State private var isProcessing = false
    @State private var showAddedToCart = false
    @State private var imageCache: UIImage?
    @StateObject private var paymentVM = PaymentViewModel()
    
    private let maxQuantity = 10
    private let minQuantity = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    medicineImage
                    medicineDetails
                    medicineInfo
                    quantitySelector
                    priceDetails
                    actionButtons
                }
                .padding(.horizontal)
                .padding(.bottom, 150)
            }
            .navigationTitle("Medicine Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var medicineImage: some View {
        Group {
            if let cachedImage = imageCache {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                AsyncImage(url: URL(string: medicine.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onAppear {
                                if let uiImage = image.asUIImage() {
                                    imageCache = uiImage
                                }
                            }
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
        .clipped()
    }
    
    private var medicineDetails: some View {
        VStack(spacing: 8) {
            Text(medicine.name)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)
                .fixedSize(horizontal: false, vertical: true)

            Text(medicine.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 20)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var medicineInfo: some View {
        VStack(spacing: 16) {
            // Category
            if let category = medicine.category {
                InfoRow(
                    icon: "tag.fill",
                    title: "Category",
                    value: category.rawValue,
                    color: .blue
                )
            }
            
            // Prescription Requirement
            if let requiresPrescription = medicine.isPrescriptionRequired {
                InfoRow(
                    icon: requiresPrescription ? "doc.text.fill" : "doc.text",
                    title: "Prescription",
                    value: requiresPrescription ? "Required" : "Not Required",
                    color: requiresPrescription ? .orange : .green
                )
            }
            
            // Availability
            if let isAvailable = medicine.isAvailable {
                InfoRow(
                    icon: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill",
                    title: "Availability",
                    value: isAvailable ? "In Stock" : "Out of Stock",
                    color: isAvailable ? .green : .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quantitySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quantity")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 20) {
                quantityButton(action: decrementQuantity, icon: "minus.circle.fill", isEnabled: quantity > minQuantity)
                
                Text("\(quantity)")
                    .font(.title2)
                    .frame(width: 50)
                    .foregroundColor(.primary)
                
                quantityButton(action: incrementQuantity, icon: "plus.circle.fill", isEnabled: quantity < maxQuantity)
            }
            .padding(8)
            .background(Color(.white))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
            )
        }
    }
    
    private func quantityButton(action: @escaping () -> Void, icon: String, isEnabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isEnabled ? .accent : .gray)
        }
        .disabled(!isEnabled)
    }
    
    private var priceDetails: some View {
        Text("Total: \(medicine.points * quantity) $")
            .font(.headline)
            .foregroundColor(.accent)
            .padding(.top, 10)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: addToCart) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(medicine.isAvailable == false)

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
            .disabled(isProcessing || medicine.isAvailable == false)
            
            if showAddedToCart {
                Text("Added to cart!")
                    .foregroundColor(.green)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Actions
    
    private func incrementQuantity() {
        guard quantity < maxQuantity else { return }
        quantity += 1
    }
    
    private func decrementQuantity() {
        guard quantity > minQuantity else { return }
        quantity -= 1
    }
    
    private func addToCart() {
        cartVM.addToCart(medicine: medicine, quantity: quantity)
        withAnimation {
            showAddedToCart = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showAddedToCart = false
            }
        }
    }
    
    private func buyNow() {
        isProcessing = true
        PharmacyViewModel().placeOrder(medicine: medicine, userId: userId, quantity: quantity) { error in
            isProcessing = false
            if error == nil {
                onOrderSuccess()
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.subheadline)
    }
}

// MARK: - Image Extension
extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
