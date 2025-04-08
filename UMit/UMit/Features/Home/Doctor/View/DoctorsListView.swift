import SwiftUI

struct DoctorsListView: View {
    @StateObject var viewModel = DoctorsViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.doctors) { doctor in
                NavigationLink(destination: DoctorDetailView(doctor: doctor).environmentObject(viewModel)) {
                    HStack {
                        AsyncImage(url: URL(string: doctor.imageURL ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(doctor.fullName)
                                .font(.headline)
                            Text(doctor.specialty)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("\(doctor.experience) yrs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Doctors")
        }
    }
}
