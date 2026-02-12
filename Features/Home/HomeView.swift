import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Enter a word or Chinese term", text: $vm.inputWord)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                Button {
                    Task { await vm.generateAndSave() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Generate and Save")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)

                Text(vm.statusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("EtyNote")
        }
    }
}
