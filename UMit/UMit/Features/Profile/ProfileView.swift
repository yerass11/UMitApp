import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var fullName = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("My profile")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                
                HStack {
                    Image("profile_photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                }
                Text(fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                List {
                    Section {
                        NavigationLink(destination: AccountTabView()) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Profile")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                        
                        NavigationLink(destination: FavoriteView()) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.blue)
                                Text("Favorite")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                        
//                        NavigationLink(destination: PaymentMethodView()) {
//                            HStack {
//                                Image(systemName: "creditcard.fill")
//                                    .foregroundColor(.blue)
//                                Text("Payment Method")
//                                    .foregroundColor(.blue)
//                                Spacer()
//                            }
//                        }

                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.blue)
                                Text("Privacy Policy")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }

                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.blue)
                                Text("Settings")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }

                        NavigationLink(destination: HelpView()) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Help")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }

                        Button(role: .destructive) {
                            viewModel.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.red)
                                Text("Logout")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            loadData()
        }
        .background(Color(white: 0.95))
    }

    private func loadData() {
        if let user = viewModel.user {
            fullName = user.displayName ?? "No Name Available"
        } else {
            fullName = "No User Logged In"
        }
    }
}

// MARK: Profile Preview
struct Profile_Preview: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
