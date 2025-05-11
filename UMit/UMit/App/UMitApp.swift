import Firebase
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import Stripe

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct UMitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var cartVM = CartViewModel()
    
    init() {
        StripeAPI.defaultPublishableKey = "pk_test_51RCgvsCIOnZjCZSg1BjbesSFk0ix0FdamTcaiGXcc9ayRZJRBgOCF6chWThJ4XK2AY13PMtat0FgQrLjMyVSM5bW00E8JGuxSY"
    }
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(cartVM)
        }
    }
}
