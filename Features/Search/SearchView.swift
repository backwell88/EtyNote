import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    TextField("Search title", text: $vm.keyword)
                        .textFieldStyle(.roundedBorder)

                    Button("Go") {
                        vm.search()
                    }
                }

                List {
                    ForEach(vm.filteredTitles, id: \.self) { title in
                        NavigationLink(destination: DetailView(title: title)) {
                            Text(title)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.delete(word: title)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Text(vm.statusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("Search")
            .onAppear { vm.loadTitles() }
        }
    }
}
