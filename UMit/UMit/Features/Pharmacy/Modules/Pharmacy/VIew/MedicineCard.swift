import SwiftUI

struct MedicineCard: View {
    let medicine: Medicine

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: medicine.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.name)
                    .font(.headline)
                Text(medicine.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
            Text("\(medicine.points) $")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
