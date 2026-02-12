import SwiftUI

struct ReviewView: View {
    @StateObject private var vm = ReviewViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button("Reload Today") {
                    vm.loadToday()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                List(vm.titles, id: \.self) { title in
                    NavigationLink(destination: DetailView(title: title)) {
                        Text(title)
                    }
                }
                .listStyle(.plain)

                Text(vm.statusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Review")
            .onAppear { vm.loadToday() }
        }
    }
}
