import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @State private var exportDocument = MarkdownTextDocument()
    @State private var isExporterPresented: Bool = false
    @State private var isImporterPresented: Bool = false

    var body: some View {
        NavigationStack {
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
                    Button("Export to Files") {
                        startExport()
                    }

                    Button("Import from Files") {
                        isImporterPresented = true
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
            .fileExporter(
                isPresented: $isExporterPresented,
                document: exportDocument,
                contentType: markdownContentType,
                defaultFilename: exportFilename
            ) { result in
                switch result {
                case .success:
                    vm.statusMessage = "Export completed. Check the Files app."
                case .failure(let error):
                    vm.statusMessage = "Export failed: \(error.localizedDescription)"
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [markdownContentType],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let fileURL = urls.first else {
                        vm.statusMessage = "No file selected."
                        return
                    }
                    vm.importMarkdownAppend(from: fileURL)
                case .failure(let error):
                    vm.statusMessage = "Import failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private var exportFilename: String {
        "EtyNote-\(dateStamp())"
    }

    private var markdownContentType: UTType {
        UTType(filenameExtension: "md") ?? .plainText
    }

    private func startExport() {
        do {
            exportDocument = try vm.prepareExportDocument()
            isExporterPresented = true
            if exportDocument.text.isEmpty {
                vm.statusMessage = "No entries found. An empty markdown file will be exported."
            }
        } catch {
            vm.statusMessage = ErrorMessageService.message(for: error)
        }
    }

    private func dateStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmm"
        return formatter.string(from: Date())
    }
}

struct MarkdownTextDocument: FileDocument {
    static var readableContentTypes: [UTType] = [
        UTType(filenameExtension: "md") ?? .plainText,
        .plainText
    ]

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let text = String(data: data, encoding: .utf8) {
            self.text = text
            return
        }

        self.text = ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}
