import SwiftUI

struct ProfileView: View {
    @State private var fullName: String = "Saiman Yerassyl"
    @State private var email: String = "y_saiman@kbtu.kz"
    @State private var phoneNumber: String = "707 720 0569"
    @State private var gender: String = "Man"
    @State private var birthDate: String = "14 March, 2005"

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Text("My Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Image("flag_usa")
                        .resizable()
                        .frame(width: 33, height: 17)
                }
                .padding(.top, 10)
                .padding(.horizontal, 16)
                
                HStack {
                    Image("profile_photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    
                    Text(fullName)
                        .frame(width: 150)
                        .font(.system(size: 24, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                        Text("My Point")
                            .font(.caption)
                        Text("0 Point")
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ProfileField(title: "Full Name", value: fullName)
                ProfileField(title: "Email", value: email)
                ProfileField(title: "Phone Number", value: "+7 \(phoneNumber)")
                ProfileField(title: "Gender", value: gender)
                ProfileField(title: "Date Of Birth", value: birthDate)
            }
            .padding()
            
            Button(action: {
            }) {
                Text("Change Profile")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack(alignment: .center, spacing: 24) {
                Text("Terms and Conditions")
                Text("Privacy Policy")
                Text("Contact Us")
                Text("FAQ")
                Text("Exit")
                    .foregroundColor(.red)
            }
            .font(.caption)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct ProfileField: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
}
