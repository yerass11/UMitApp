import SwiftUI

struct MinimalTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.gray)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                        .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                        .autocapitalization(.none)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .bottom
            )
        }
    }
}
