import SwiftUI

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.reviewerName)
                    .font(.headline)
                Spacer()
                Text("⭐️ \(review.rating)")
                    .font(.subheadline)
            }

            Text(review.comment)
                .font(.body)

            Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
