import SwiftUI

struct HospitalDetailView: View {
    let hospital: Hospital
    @StateObject var reviewsVM = ReviewViewModel()
    @State private var showReviewForm = false


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Изображение больницы
                AsyncImage(url: URL(string: hospital.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)

                // Название
                Text(hospital.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Адрес
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                    Text(hospital.address)
                }

                // Телефон
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(hospital.phone)
                }

                // Рейтинг
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Рейтинг: \(String(format: "%.1f", hospital.rating))")
                }
                VStack {
                    ReviewsSectionView(viewModel: reviewsVM)

                    Button("Оставить отзыв") {
                        showReviewForm = true
                    }
                    .sheet(isPresented: $showReviewForm) {
                        ReviewFormView(hospitalId: hospital.id)
                    }
                }
                .onAppear {
                    reviewsVM.fetchReviews(hospitalId: hospital.id)
                }
                
                

                Spacer()
            }
            .padding()
        }
        .navigationTitle("О больнице")
        .navigationBarTitleDisplayMode(.inline)
    }
}
