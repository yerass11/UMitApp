import SwiftUI

struct ChatListView: View {
    let userId: String
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showTab: Bool

    @State private var recentChats: [ChatGroup] = []
    @State private var navigateToDoctors = false

    var body: some View {
        NavigationView {
            Group {
                if recentChats.isEmpty {
                    EmptyStateView(navigateToDoctors: $navigateToDoctors)
                } else {
                    List(recentChats) { chat in
                        NavigationLink(
                            destination: ChatView(doctor: chat.doctor, userId: userId, showTab: $showTab)
                        ) {
                            ChatRowView(doctor: chat.doctor)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigateToDoctors = true
                    } label: {
                        Image(systemName: "plus.app")
                            .imageScale(.large)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: DoctorsListView(authViewModel: viewModel, showTab: $showTab),
                    isActive: $navigateToDoctors
                ) {
                    EmptyView()
                }
            )
            .onAppear {
                showTab = true
                ChatService.fetchChats(for: userId) { chats in
                    self.recentChats = chats
                }
            }
        }
    }
}

private struct EmptyStateView: View {
    @Binding var navigateToDoctors: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("No messages yet")
                .foregroundColor(.gray)

            Button("Find a Doctor") {
                navigateToDoctors = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ChatRowView: View {
    let doctor: ChatDoctor

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: doctor.imageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(doctor.fullName)
                    .font(.headline)
                Text(doctor.specialty)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
