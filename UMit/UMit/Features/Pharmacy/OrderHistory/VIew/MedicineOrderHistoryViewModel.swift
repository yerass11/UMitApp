import SwiftUI

final class MedicineOrderHistoryViewModel: ObservableObject {
    @Published var orders: [MedicineOrder] = []

    func loadOrders(userId: String) {
        print("✅ Orders fetched:", orders.count)
        orders.forEach { print("• \($0.medicineName) - \($0.timestamp)") }

        MedicineOrderService.shared.fetchOrders(for: userId) { [weak self] fetched in
            DispatchQueue.main.async {
                self?.orders = fetched
            }
        }
    }
}
