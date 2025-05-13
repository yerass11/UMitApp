import Foundation
import FirebaseFirestore

class ReviewViewModel: ObservableObject {
    @Published var reviews: [Review] = []

    private let db = Firestore.firestore()

    func fetchReviews(forDoctorId doctorId: String? = nil, hospitalId: String? = nil) {
        var query: Query = db.collection("reviews")

        if let doctorId = doctorId {
            query = query.whereField("doctorId", isEqualTo: doctorId)
        } else if let hospitalId = hospitalId {
            query = query.whereField("hospitalId", isEqualTo: hospitalId)
        }

        query.order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.reviews = documents.compactMap { try? $0.data(as: Review.self) }
                print("Loaded \(self.reviews.count) reviews")
            } else {
                print("Error loading reviews: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func addReview(review: Review, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("reviews").addDocument(from: review) { error in
                if error == nil {
                    self.updateAverageRating(for: review)
                }
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    private func updateAverageRating(for review: Review) {
        var query: Query = db.collection("reviews")

        if let doctorId = review.doctorId {
            query = query.whereField("doctorId", isEqualTo: doctorId)
        } else if let hospitalId = review.hospitalId {
            query = query.whereField("hospitalId", isEqualTo: hospitalId)
        } else {
            return
        }

        query.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            let ratings = docs.compactMap { try? $0.data(as: Review.self).rating }
            let avg = ratings.reduce(0, +) / Double(ratings.count)

            if let doctorId = review.doctorId {
                self.db.collection("doctors").document(doctorId).updateData([
                    "rating": avg
                ])
            } else if let hospitalId = review.hospitalId {
                self.db.collection("hospitals").document(hospitalId).updateData([
                    "rating": avg
                ])
            }
        }
    }
}
