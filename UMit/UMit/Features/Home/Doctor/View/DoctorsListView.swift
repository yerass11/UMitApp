import SwiftUI

struct DoctorsListView: View {
    let authViewModel: AuthViewModel
    
    @StateObject var viewModel = DoctorsViewModel()
    @Binding var showTab: Bool
    
    var body: some View {
        List(viewModel.doctors) { doctor in
            NavigationLink(destination: DoctorDetailView(doctor: doctor, showTab: $showTab).environmentObject(authViewModel)) {
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
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .foregroundColor(.accent)
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
        .onAppear {
            showTab = false
        }
    }
}
