import Foundation

enum MarkdownTransferServiceError: Error {
    case invalidImportFormat
}

struct MarkdownImportResult {
    let importedCount: Int
    let skippedDuplicateCount: Int
}

enum MarkdownTransferService {
    static func exportMarkdown(in documentsURL: URL) throws -> String {
        try MarkdownStoreService.loadMarkdown(in: documentsURL)
    }

    static func importMarkdownReplace(_ markdown: String, in documentsURL: URL) throws {
        let fm = FileManager.default
        let folderURL = documentsURL.appendingPathComponent(FileService.folderName, isDirectory: true)
        let fileURL = folderURL.appendingPathComponent(FileService.fileName)

        if !fm.fileExists(atPath: folderURL.path) {
            try fm.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    static func importMarkdownReplace(from sourceURL: URL, in documentsURL: URL) throws {
        let markdown = try String(contentsOf: sourceURL, encoding: .utf8)
        try importMarkdownReplace(markdown, in: documentsURL)
    }

    static func importMarkdownAppendStrict(
        from sourceURL: URL,
        in documentsURL: URL
    ) throws -> MarkdownImportResult {
        let ext = sourceURL.pathExtension.lowercased()
        if !ext.isEmpty && ext != "md" && ext != "txt" {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        let importedMarkdown = try String(contentsOf: sourceURL, encoding: .utf8)
        let importEntries = try parseEntriesForStrictImport(from: importedMarkdown)
        guard !importEntries.isEmpty else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        let existingMarkdown = try exportMarkdown(in: documentsURL)
        var existingTitles = Set(
            IndexService.extractTitles(from: existingMarkdown).map { $0.lowercased() }
        )

        var blocksToAppend: [String] = []
        var seenInImport: Set<String> = []
        var importedCount = 0
        var skippedDuplicateCount = 0

        for entry in importEntries {
            let key = entry.title.lowercased()
            if existingTitles.contains(key) || seenInImport.contains(key) {
                skippedDuplicateCount += 1
                continue
            }

            seenInImport.insert(key)
            existingTitles.insert(key)
            importedCount += 1
            blocksToAppend.append(normalizeBlockForAppend(entry.block))
        }

        for block in blocksToAppend {
            try FileService.append(block, in: documentsURL)
        }

        return MarkdownImportResult(
            importedCount: importedCount,
            skippedDuplicateCount: skippedDuplicateCount
        )
    }

    private struct ParsedEntry {
        let title: String
        let block: String
    }

    private static func parseEntriesForStrictImport(from markdown: String) throws -> [ParsedEntry] {
        let blocks = try splitStrictBlocks(in: markdown)

        return try blocks.map { block in
            let title = try validateAndExtractTitle(from: block)
            return ParsedEntry(title: title, block: block)
        }
    }

    private static func splitStrictBlocks(in markdown: String) throws -> [String] {
        let lines = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        var result: [String] = []
        var i = 0

        while i < lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                i += 1
                continue
            }

            guard trimmed == "---" else {
                throw MarkdownTransferServiceError.invalidImportFormat
            }

            var j = i + 1
            while j < lines.count && lines[j].trimmingCharacters(in: .whitespaces) != "---" {
                j += 1
            }
            if j < lines.count {
                result.append(lines[i...j].joined(separator: "\n"))
                i = j + 1
                continue
            }
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        guard !result.isEmpty else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        return result
    }

    private enum SectionType {
        case list
        case morphology
    }

    private static func validateAndExtractTitle(from block: String) throws -> String {
        let normalized = block.replacingOccurrences(of: "\r\n", with: "\n")
        var lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard lines.count >= 3 else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---",
              lines.last?.trimmingCharacters(in: .whitespaces) == "---" else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        lines.removeFirst()
        lines.removeLast()

        var index = 0

        func nextNonEmptyTrimmedLine() -> String? {
            while index < lines.count {
                let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
                index += 1
                if !trimmed.isEmpty {
                    return trimmed
                }
            }
            return nil
        }

        guard let titleLine = nextNonEmptyTrimmedLine(), titleLine.hasPrefix("# ") else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        let title = String(titleLine.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw MarkdownTransferServiceError.invalidImportFormat
        }

        let expectedSections: [(String, SectionType)] = [
            ("## Part of Speech", .list),
            ("## English Meaning", .list),
            ("## Chinese Meaning", .list),
            ("## Root", .morphology),
            ("## Prefix", .morphology),
            ("## Suffix", .morphology),
            ("## Related Words", .list),
            ("## Variants", .list)
        ]

        for (sectionHeader, sectionType) in expectedSections {
            guard let headerLine = nextNonEmptyTrimmedLine(), headerLine == sectionHeader else {
                throw MarkdownTransferServiceError.invalidImportFormat
            }

            switch sectionType {
            case .list:
                var itemCount = 0
                while let line = nextNonEmptyTrimmedLine() {
                    if line.hasPrefix("## ") {
                        index -= 1
                        break
                    }
                    guard line.hasPrefix("- ") else {
                        throw MarkdownTransferServiceError.invalidImportFormat
                    }
                    itemCount += 1
                }

                guard itemCount > 0 else {
                    throw MarkdownTransferServiceError.invalidImportFormat
                }

            case .morphology:
                let requiredPrefixes = ["- Form:", "- Meaning:", "- Origin:"]
                for prefix in requiredPrefixes {
                    guard let line = nextNonEmptyTrimmedLine(), line.hasPrefix(prefix) else {
                        throw MarkdownTransferServiceError.invalidImportFormat
                    }
                }
            }
        }

        while let trailing = nextNonEmptyTrimmedLine() {
            if !trailing.isEmpty {
                throw MarkdownTransferServiceError.invalidImportFormat
            }
        }

        return title
    }

    private static func normalizeBlockForAppend(_ block: String) -> String {
        var result = block.replacingOccurrences(of: "\r\n", with: "\n")
        if !result.hasSuffix("\n") {
            result += "\n"
        }
        if !result.hasSuffix("\n\n") {
            result += "\n"
        }
        return result
    }
}
