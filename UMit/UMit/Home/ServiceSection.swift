import SwiftUI

struct ServiceSection: View {
    let title: String
    let services: [Service]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<services.count, id: \.self) { index in
                        Button(action: {
                            print("tapped another")
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(services[index].backgroundColor)
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: services[index].icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(services[index].color)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
