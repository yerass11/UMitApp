import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var historyVM = MedicineOrderHistoryViewModel()

    var body: some View {
        VStack {
            if historyVM.orders.isEmpty {
                Text("No orders yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(historyVM.orders) { order in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: order.imageURL)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.medicineName)
                                .font(.headline)
                            Text("\(order.quantity) pcs • \(order.points * order.quantity) $")
                                .font(.subheadline)
                                .foregroundColor(.accent)
                            Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
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
    }
}
