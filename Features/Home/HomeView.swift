import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("EtyNote")
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            TextField("Enter a word or Chinese term", text: $vm.inputWord)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled(true)

                            Button("Paste") {
                                vm.pasteFromClipboard()
                            }
                            .buttonStyle(.bordered)
                        }

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

                        Spacer(minLength: max(24, proxy.size.height * 0.12))
                    }
                    .padding(.horizontal, horizontalPadding(for: proxy.size.width))
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(.systemBackground))
            }
            .navigationDestination(for: String.self) { title in
                DetailView(title: title)
            }
            .onChange(of: vm.generatedTitle) { _, newTitle in
                guard let title = newTitle, !title.isEmpty else { return }
                path.append(title)
                vm.generatedTitle = nil
            }
        }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        min(max(width * 0.06, 16), 28)
    }
}
