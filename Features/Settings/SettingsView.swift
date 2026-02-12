import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section("API") {
                    TextField("Base URL", text: $vm.baseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    SecureField("API Key", text: $vm.apiKey)
                }

                Section("Review") {
                    Toggle("Enable Daily Review", isOn: $vm.reviewEnabled)
                    TextField("Daily Count", text: $vm.reviewDailyCountText)
                        .keyboardType(.numberPad)
                }

                Section("Markdown Transfer") {
                    HStack {
                        Button("Export") { vm.exportMarkdown() }
                        Button("Import Replace") { vm.importMarkdownReplace() }
                    }

                    TextEditor(text: $vm.markdownTransferText)
                        .frame(minHeight: 180)
                }

                Section {
                    Button("Save Settings") {
                        Task { await vm.save() }
                    }
                }

                Section {
                    Text(vm.statusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .onAppear { vm.load() }
        }
    }
}
