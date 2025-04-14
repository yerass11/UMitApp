import SwiftUI

struct HospitalsListView: View {
    @StateObject var viewModel = HospitalsViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.hospitals) { hospital in
                NavigationLink(destination: HospitalDetailView(hospital: hospital)) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: hospital.imageURL ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(hospital.name)
                                .font(.headline)
                            Text(hospital.address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("⭐️ \(String(format: "%.1f", hospital.rating))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Hospitals")
        }
    }
}
