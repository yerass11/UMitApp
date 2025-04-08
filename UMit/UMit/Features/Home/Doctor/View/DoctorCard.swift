import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor
    let viewModel: AuthViewModel

    var body: some View {
        NavigationLink(destination: DoctorDetailView(doctor: doctor).environmentObject(viewModel)) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: doctor.imageURL ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor.fullName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.specialty)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(doctor.experience) yrs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}
