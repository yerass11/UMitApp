import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AuthViewModel()
    
    @State var showTab: Bool = true
    @State var selectedTab: TabIcon = .home
    
    var body: some View {
        NavigationView {
            if viewModel.user != nil {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView(viewModel: viewModel, showTab: $showTab)
                            .environmentObject(viewModel)
                    case .message:
                        HomeView(viewModel: viewModel, showTab: $showTab)
                    case .pharmacy:
                        HomeView(viewModel: viewModel, showTab: $showTab)
                    case .profile:
                        ProfileView()
                            .environmentObject(viewModel)
                    }
                }
                .overlay(alignment: .bottom) {
                    if showTab {
                        CustomTabBar(selectedTab: $selectedTab)
                            .transition(.offset(y: 300))
                    }
                }
                
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
