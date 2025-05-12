import SwiftUI

struct ServiceButton: View {
    let icon: String
    let color: Color
    let backgroundColor: Color
    let title: String
    
    var body: some View {
        Button(action: {
            print("tapped!")
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColor)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
                    .foregroundStyle(.black)
            }
        }
    }
}

struct Service {
    let icon: String
    let color: Color
    let backgroundColor: Color
}
