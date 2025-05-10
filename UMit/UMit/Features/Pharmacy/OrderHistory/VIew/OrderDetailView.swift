import SwiftUI

struct OrderDetailView: View {
    let order: MedicineOrder
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Order Items List
                VStack(spacing: 16) {
                    ForEach(order.items, id: \.medicineId) { item in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: item.imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.medicineName)
                                    .font(.headline)
                                Text("\(item.quantity) pcs • \(item.totalPoints) $")
                                    .font(.subheadline)
                                    .foregroundColor(.accent)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                // Order Summary Card
                VStack(spacing: 16) {
                    InfoRow(
                        icon: "number.circle.fill",
                        title: "Total Items",
                        value: "\(order.quantity) pieces",
                        color: .green
                    )
                    
                    InfoRow(
                        icon: "dollarsign.circle.fill",
                        title: "Total Points",
                        value: "\(order.totalPoints) $",
                        color: .orange
                    )
                    
                    InfoRow(
                        icon: "calendar",
                        title: "Order Date",
                        value: order.timestamp.formatted(date: .long, time: .shortened),
                        color: .purple
                    )
                    
                    InfoRow(
                        icon: "tag.fill",
                        title: "Order ID",
                        value: order.id,
                        color: .gray
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Order Status
                VStack(spacing: 12) {
                    Text("Order Status")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
} 