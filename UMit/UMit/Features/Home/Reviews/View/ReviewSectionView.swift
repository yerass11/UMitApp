import SwiftUI

struct ReviewsSectionView: View {
    @ObservedObject var viewModel: ReviewViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отзывы")
                .font(.title3.bold())

            if viewModel.reviews.isEmpty {
                Text("Пока нет отзывов.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.reviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(review.reviewerName)
                                .font(.headline)
                            Spacer()
                            Text("\(String(format: "%.1f", review.rating)) ⭐️")
                                .foregroundColor(.yellow)
                        }
                        Text(review.comment)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.top)
    }
}
