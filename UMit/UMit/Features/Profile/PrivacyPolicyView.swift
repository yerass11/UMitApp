import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            HStack {
                Spacer()
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)

            // Дата последнего обновления
            Text("Last Update: 14/08/2024")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)

            // Контент политики конфиденциальности
            ScrollView {
                Text("""
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam. Fusce a scelerisque neque, sed accumsan metus.

                Nunc auctor tortor in dolor luctus, quis euismod urna tincidunt. Aenean arcu metus, bibendum at rhoncus at, volutpat ut lacus. Morbi pellentesque malesuada eros semper ultrices. Vestibulum lobortis enim vel neque auctor, a ultricies ex placerat. Mauris ut lacinia justo, sed suscipit tortor. Nam egestas nulla posuere neque tincidunt porta.
                """)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .lineSpacing(5)

                // Условия
                VStack(alignment: .leading) {
                    Text("Terms & Conditions")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top)

                    ForEach(1..<6) { index in
                        Text("""
                        \(index). Ut lacinia justo sit amet lorem sodales accumsan. Proin malesuada eleifend fermentum. Donec condimentum, nunc at rhoncus faucibus, ex nisi laoreet ipsum, eu pharetra eros est vitae orci. Morbi quis rhoncus mi. Nullam lacinia ornare accumsan.
                        """)
                            .font(.body)
                            .padding(.vertical, 5)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
