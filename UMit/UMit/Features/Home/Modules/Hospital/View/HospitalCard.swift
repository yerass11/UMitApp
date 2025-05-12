import SwiftUI

struct HospitalCard: View {
    let hospital: Hospital
    let viewModel: AuthViewModel

    var body: some View {
        NavigationLink(destination: HospitalDetailView(hospital: hospital).environmentObject(viewModel)) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: hospital.imageURL ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    Text(hospital.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accent)

                    Text(hospital.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Телефон: \(hospital.phone)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("⭐️ \(String(format: "%.1f", hospital.rating))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
            .shadow(radius: 2)
        }
    }
}
