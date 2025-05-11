import SwiftUI

struct AppointmentCardView: View {
    let appointment: Appointment
    var onDelete: () -> Void
    var onEdit: () -> Void

    @State private var showOptions = false

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: appointment.timestamp)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.accent)
                .padding(10)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName)
                    .font(.headline)

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Clinic Visit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.accent)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
