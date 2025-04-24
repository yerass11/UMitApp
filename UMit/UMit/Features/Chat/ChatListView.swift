import SwiftUI

struct ChatListView: View {
    let userId: String
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showTab: Bool

    @State private var recentChats: [ChatGroup] = []
    @State private var showDoctorsList = false

    var body: some View {
        NavigationView {
            Group {
                if recentChats.isEmpty {
                    VStack(spacing: 16) {
                        Text("No messages yet")
                            .foregroundColor(.gray)

                        Button(action: {
                            showDoctorsList = true
                        }) {
                            Text("Find a Doctor")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(recentChats) { chat in
                        NavigationLink(destination: ChatView(doctor: chat.doctor, userId: userId)) {
                            HStack {
                                AsyncImage(url: URL(string: chat.doctor.imageURL ?? "")) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(chat.doctor.fullName)
                                        .font(.headline)
                                    Text(chat.doctor.specialty)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                ChatService.fetchChats(for: userId) { chats in
                    self.recentChats = chats
                }
            }
            .sheet(isPresented: $showDoctorsList) {
                DoctorsListView(authViewModel: viewModel, showTab: $showTab)
            }
        }
    }
}
