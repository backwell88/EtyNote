import SwiftUI

struct ReviewView: View {
    @StateObject private var vm = ReviewViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Button("Reload Today") {
                    vm.loadToday()
                }
                .buttonStyle(.borderedProminent)

                List(vm.titles, id: \.self) { title in
                    NavigationLink(destination: DetailView(title: title)) {
                        Text(title)
                    }
                }

                Text(vm.statusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("Review")
            .onAppear { vm.loadToday() }
        }
    }
}
