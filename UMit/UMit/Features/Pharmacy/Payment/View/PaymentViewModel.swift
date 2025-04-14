import Foundation
import Stripe
import StripePaymentSheet
import UIKit

class PaymentViewModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    
    /// Получает PaymentIntent от backend и создает PaymentSheet с конфигурацией.
    func fetchPaymentIntent(amount: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/create-payment-intent/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["amount": amount])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let clientSecret = json["client_secret"] as? String else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                var config = PaymentSheet.Configuration()
                config.merchantDisplayName = "UMit Pharmacy"
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
                completion(true)
            }
        }.resume()
    }

    func presentPaymentSheet(completion: @escaping (PaymentSheetResult) -> Void) {
        guard let paymentSheet = paymentSheet,
              let root = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let controller = root.windows.first?.rootViewController else { return }
        
        paymentSheet.present(from: controller) { result in
            completion(result)
        }
    }
}
