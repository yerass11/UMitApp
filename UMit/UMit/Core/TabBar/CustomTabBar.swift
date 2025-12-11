import SwiftUI

struct CustomTabBar: View {
    let tabItems = [
        TabBar(iconName: "house", tab: .home),
        TabBar(iconName: "message", tab: .message),
        TabBar(iconName: "pill", tab: .pharmacy),
        TabBar(iconName: "person.crop.circle", tab: .profile),
    ]
    @Binding var selectedTab: TabIcon
    @Namespace var animationNamespace
    
    var body: some View {
        HStack {
            ForEach(tabItems) { item in
                Spacer()
                
                Image(systemName: item.iconName)
                    .font(.title2)
                    .symbolVariant(selectedTab == item.tab ? .fill : .none)
                    .contentTransition(.symbolEffect)
                    .foregroundStyle(selectedTab == item.tab ? Color.primary : .gray)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedTab = item.tab
                        }
                    }
                    .background {
                        Group {
                            if selectedTab == item.tab {
                                Circle()
                                    .frame(width: 70)
                                    .foregroundStyle(Color(.systemGray4))
                                    .matchedGeometryEffect(id: "circle", in: animationNamespace)
                            }
                        }
                    }
                Spacer()
            }
        }
        .frame(height: 80)
        .background(Color(.systemGray6), in: .capsule)
        .padding(.horizontal, 10)
    }
}
