import SwiftUI

struct CartView: View {
    @EnvironmentObject var viewModel: CartViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckout = false
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.items.isEmpty {
                    emptyCartView
                } else {
                    cartItemsList
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Your cart is empty")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    private var cartItemsList: some View {
        VStack {
            List {
                ForEach(viewModel.items) { item in
                    CartItemRow(item: item) { newQuantity in
                        viewModel.updateQuantity(medicineId: item.medicineId, quantity: newQuantity)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removeFromCart(medicineId: viewModel.items[index].medicineId)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            VStack(spacing: 16) {
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("\(viewModel.totalPoints) $")
                        .font(.headline)
                        .foregroundColor(.accent)
                }
                .padding(.horizontal)
                
                Button {
                    placeOrder()
                } label: {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Proceed to Checkout")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isProcessing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isProcessing)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .shadow(radius: 2)
        }
    }
    
    private func placeOrder() {
        guard let userId = authViewModel.user?.uid else {
            errorMessage = "Please sign in to place an order"
            showError = true
            return
        }
        
        isProcessing = true
        viewModel.createOrder(userId: userId) { error in
            isProcessing = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                dismiss()
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.medicineName)
                    .font(.headline)
                Text("\(item.points) $")
                    .font(.subheadline)
                    .foregroundColor(.accent)
            }
            
            Spacer()
            
            HStack {
                Button {
                    onQuantityChange(item.quantity - 1)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.gray)
                }
                
                Text("\(item.quantity)")
                    .frame(minWidth: 30)
                
                Button {
                    onQuantityChange(item.quantity + 1)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct CheckoutView: View {
    let order: MedicineOrder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Order Placed Successfully!")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Details:")
                        .font(.headline)
                    
                    Text("Items: \(order.medicineName)")
                    Text("Total Points: \(order.points)")
                    Text("Quantity: \(order.quantity)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 