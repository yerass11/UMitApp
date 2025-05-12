import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var historyVM = MedicineOrderHistoryViewModel()
    @State private var selectedOrder: MedicineOrder?

    var body: some View {
        VStack {
            if historyVM.orders.isEmpty {
                Text("No orders yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(historyVM.orders) { order in
                    Button {
                        selectedOrder = order
                    } label: {
                        HStack(spacing: 12) {
                            if order.items.count == 1 {
                                AsyncImage(url: URL(string: order.items[0].imageURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                if order.items.count == 1 {
                                    Text(order.items[0].medicineName)
                                        .font(.headline)
                                } else {
                                    Text("\(order.items.count) items")
                                        .font(.headline)
                                }
                                
                                Text("\(order.quantity) pcs • \(order.totalPoints) $")
                                    .font(.subheadline)
                                    .foregroundColor(.accent)
                                
                                Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Order History")
        .onAppear {
            if let uid = viewModel.user?.uid {
                historyVM.loadOrders(userId: uid)
            } else {
                print("❌ No userId")
            }
        }
        .sheet(item: $selectedOrder) { order in
            NavigationView {
                OrderDetailView(order: order)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                selectedOrder = nil
                            }
                        }
                    }
            }
        }
    }
}
