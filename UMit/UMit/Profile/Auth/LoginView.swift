import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var fullName: String = ""

    @State private var isLoginMode = true
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Заголовок
            VStack(alignment: .leading, spacing: 6) {
                Text(isLoginMode ? "Welcome 👋" : "Create Account")
                    .font(.system(size: 32, weight: .bold))

                Text(isLoginMode ? "Login to continue" : "Register to get started")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut.delay(0.1), value: showContent)

            // Поля ввода
            VStack(spacing: 20) {
                if !isLoginMode {
                    MinimalTextField(text: $fullName, placeholder: "Full Name", isSecure: false)
                }
                MinimalTextField(text: $email, placeholder: "Email", isSecure: false)
                MinimalTextField(text: $password, placeholder: "Password", isSecure: true)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut.delay(0.2), value: showContent)

            // Ошибка
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Кнопка входа/регистрации
            Button(action: {
                withAnimation {
                    if isLoginMode {
                        viewModel.signIn(email: email, password: password)
                    } else {
                        viewModel.signUp(email: email, password: password, fullName: fullName)
                    }
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary)
                        .frame(height: 52)
                        .scaleEffect(viewModel.isLoading ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isLoginMode ? "Login" : "Register")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .medium))
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.8 : 1)

            // Переключение режима
            HStack(spacing: 4) {
                Text(isLoginMode ? "Don't have an account?" : "Already have an account?")
                    .foregroundColor(.gray)
                    .font(.footnote)

                Button {
                    withAnimation {
                        isLoginMode.toggle()
                    }
                } label: {
                    Text(isLoginMode ? "Register" : "Login")
                        .font(.footnote.bold())
                }
            }

            Spacer()
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onAppear {
            showContent = true
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
