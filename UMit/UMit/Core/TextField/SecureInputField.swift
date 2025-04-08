import SwiftUI

struct SecureInputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            SecureField(title, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}
