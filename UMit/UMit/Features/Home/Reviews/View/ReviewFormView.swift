import SwiftUI

struct ReviewFormView: View {
    var doctorId: String? = nil
    var hospitalId: String? = nil

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ReviewViewModel()

    @State private var name = ""
    @State private var comment = ""
    @State private var rating = 3.0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ваше имя")) {
                    TextField("Имя", text: $name)
                }

                Section(header: Text("Комментарий")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }

                Section(header: Text("Оценка")) {
                    Slider(value: $rating, in: 1...5, step: 0.5)
                    Text("⭐️ \(String(format: "%.1f", rating))")
                }

                Button("Оставить отзыв") {
                    let newReview = Review(
                        reviewerName: name,
                        comment: comment,
                        rating: rating,
                        doctorId: doctorId,
                        hospitalId: hospitalId,
                        createdAt: Date()
                    )

                    viewModel.addReview(review: newReview) { error in
                        if error == nil {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Новый отзыв")
        }
    }
}
