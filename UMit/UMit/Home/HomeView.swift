import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var fullName: String? {
        viewModel.user?.displayName
    }
    var address: String = "Islam Karima 70"
    
    @State private var searchText: String = ""
    @Binding var showTab: Bool
    
    var body: some View {
        ScrollView {
            header
            addressInfo
            searchBar
            servicesInfo
            upcomingAppointments
            clinicSection
            pharmacySection
            pharmacySection
            pharmacySection
            pharmacySection
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                    geometry.contentOffset.y
                }, action: { oldValue, newValue in
                    if newValue > oldValue {
                        withAnimation {
                            showTab = false
                        }
                    } else if newValue < oldValue + 10 {
                        showTab = true
                    }
                })
    }
    
    var header: some View {
        HStack {
            VStack {
                Text("Hello!")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                if let name = fullName {
                    Text(name)
                        .font(.system(size: 24, weight: .semibold))
                }
            }
            Spacer()
            Image("profile_photo")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(.circle)
        }
        .padding(.top, 50)
        .padding(.horizontal, 8)
    }
    
    var addressInfo: some View {
        HStack {
            Image(systemName: "location.north.fill")
                .frame(width: 20, height: 20)
                .foregroundStyle(.blue)
            
            Text(address)
                .font(.system(size: 11, weight: .semibold))
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
    
    var searchBar: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(height: 50)
                    .foregroundStyle(.gray.opacity(0.3))
                
                HStack {
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search in UMit", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Spacer()
                    
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal, 8)
    }
    
    var servicesInfo: some View {
        HStack(alignment: .top, spacing: 20) {
            ServiceButton(icon: "person.fill", color: .blue, backgroundColor: Color(.systemBlue).opacity(0.2), title: "Clinic Reservation")
            ServiceButton(icon: "pill.fill", color: .red, backgroundColor: Color(.systemRed).opacity(0.2), title: "Redeem Medicine")
            ServiceButton(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2), title: "Test Covid 19")
            ServiceButton(icon: "doc.text.fill", color: .orange, backgroundColor: Color(.systemOrange).opacity(0.2), title: "Recipes")
        }
        .padding()
    }
    
    var upcomingAppointments: some View {
        VStack(alignment: .leading) {
            Text("Upcoming Appointments")
                .font(.system(size: 28, weight: .bold))
            
            AppointmentCard(images: ["covid1", "covid1"])
                .frame(height: 180)
        }
        .padding(.horizontal, 8)
    }
    
    var clinicSection: some View {
        ServiceSection(title: "Clinic Services", services: [
            Service(icon: "person.fill", color: .blue, backgroundColor: Color(.systemBlue).opacity(0.2)),
            Service(icon: "pill.fill", color: .red, backgroundColor: Color(.systemRed).opacity(0.2)),
            Service(icon: "doc.text.fill", color: .orange, backgroundColor: Color(.systemOrange).opacity(0.2)),
            Service(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2)),
            Service(icon: "calendar", color: .brown, backgroundColor: Color(.systemYellow).opacity(0.2))
        ])
    }
    
    var pharmacySection: some View {
        ServiceSection(title: "Pharmacy Services", services: [
            Service(icon: "person.fill", color: .blue, backgroundColor: Color(.systemBlue).opacity(0.2)),
            Service(icon: "pill.fill", color: .red, backgroundColor: Color(.systemRed).opacity(0.2)),
            Service(icon: "doc.text.fill", color: .orange, backgroundColor: Color(.systemOrange).opacity(0.2)),
            Service(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2)),
            Service(icon: "atom", color: .green, backgroundColor: Color(.systemGreen).opacity(0.2))
        ])
    }
}
