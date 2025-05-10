import SwiftUI

struct HelpView: View {
    @State private var selectedTab = "FAQ"
    @State private var searchText = ""
    @State private var expandedQuestion: Int? = nil
    
    let questions = [
        ("Lorem ipsum dolor sit amet?", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam."),
        ("Lorem ipsum dolor sit amet?", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam."),
        ("Lorem ipsum dolor sit amet?", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam."),
        ("Lorem ipsum dolor sit amet?", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam."),
        ("Lorem ipsum dolor sit amet?", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam. Aenean in sagittis magna, ut feugiat diam.")
    ]
    
    var body: some View {
        VStack(spacing: 32){
            // Заголовок
            Text("Help Center")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top)

            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search...", text: $searchText)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding([.leading, .trailing])
            }

            // Вкладки
            HStack {
                Button(action: { selectedTab = "FAQ" }) {
                    Text("FAQ")
                        .padding()
                        .background(selectedTab == "FAQ" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { selectedTab = "Contact Us" }) {
                    Text("Contact Us")
                        .padding()
                        .background(selectedTab == "Contact Us" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { selectedTab = "Services" }) {
                    Text("Services")
                        .padding()
                        .background(selectedTab == "Services" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding([.leading, .trailing])

            // Список вопросов
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<questions.count, id: \.self) { index in
                        VStack {
                            HStack {
                                Text(questions[index].0)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        expandedQuestion = (expandedQuestion == index) ? nil : index
                                    }
                                }) {
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(.degrees(expandedQuestion == index ? 180 : 0))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()

                            if expandedQuestion == index {
                                Text(questions[index].1)
                                    .foregroundColor(.gray)
                                    .padding([.leading, .bottom])
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(10)
        .edgesIgnoringSafeArea(.all)
        .padding(20)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
