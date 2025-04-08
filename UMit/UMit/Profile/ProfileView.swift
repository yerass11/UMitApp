import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Верхний переключатель
            Picker("Profile Tabs", selection: $selectedTab) {
                Text("Account").tag(0)
                Text("Password").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            // Свайповые вкладки
            TabView(selection: $selectedTab) {
                AccountTabView()
                    .environmentObject(viewModel)
                    .tag(0)

                PasswordTabView()
                    .environmentObject(viewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
