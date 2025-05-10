import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Spacer()
            
            List {
//                NavigationLink(destination: NotificationSettingView()) {
//                    HStack {
//                        Image(systemName: "lightbulb.fill")
//                            .foregroundColor(.blue)
//                        Text("Notification Setting")
//                            .foregroundColor(.black)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.blue)
//                    }
//                }

                NavigationLink(destination: PasswordTabView()) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.blue)
                        Text("Password Manager")
                            .foregroundColor(.black)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }.multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .listStyle(PlainListStyle())
        
        }
        .background(Color.white) // Фон для экрана
        .cornerRadius(10)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Пример для представлений, на которые будут переходить
struct NotificationSettingView: View {
    var body: some View {
        Text("Notification Settings Screen")
    }
}

struct PasswordManagerView: View {
    var body: some View {
        Text("Password Manager Screen")
    }
}

struct DeleteAccountView: View {
    var body: some View {
        Text("Delete Account Screen")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
