import SwiftUI

struct ChatListView: View {
    let userId: String
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showTab: Bool

    @State private var recentChats: [ChatGroup] = []
    @State private var navigateToDoctors = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading chats...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if recentChats.isEmpty {
                    EmptyStateView(navigateToDoctors: $navigateToDoctors)
                } else {
                    List(recentChats) { chat in
                        NavigationLink(
                            destination: ChatView(
                                doctor: chat.doctor,
                                userId: userId,
                                showTab: $showTab
                            )
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
                loadChats()
            }
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("Ок"))
                )
            }
        }
    }

    @MainActor
    func loadChats() {
        Task {
            isLoading = true
            do {
                recentChats = try await ChatService.fetchChats(for: userId)
            } catch {
                errorMessage = "Не удалось загрузить чаты: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}


extension ChatListView {
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
}

extension ChatListView {
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
}
