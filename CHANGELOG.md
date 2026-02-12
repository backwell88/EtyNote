# Changelog

## v0.2.0-local-core - 2026-02-12
- Added core models: Morphology, WordEntry
- Added local pipeline: JSONValidator -> MarkdownService -> EntryPipeline
- Added local append service: FileService, EntrySaveService
- Added title index and search: IndexService
- Tagged milestone: v0.2.0-local-core

## v0.1.0-pre-simulator - 2026-02-12
- Initialized Git repository
- Added TASKS and split v0.1 subtasks
- Added iOS .gitignore
- Added simulator run checklist (to execute on macOS)

## v0.3.0-ai-core - 2026-02-12
- Added PromptBuilder for system/user/retry prompts
- Added AIService request builder + network call + response parsing
- Added AIPipelineService with retry limit (max 3) and schema validation
- Connected generate-and-save flow through EntrySaveService
- Added AppConfigService + KeychainService for settings and API key storage
- Added DictionaryService for Chinese input resolving
- Added ErrorMessageService and display-friendly usage helper

## v0.4.0-validation-and-reliability - 2026-02-12
- Enforced strict JSON schema validation (no extra fields, required keys check)
- Switched AI pipeline to strict decoding and validation flow
- Added clearer user-facing messages for schema/format failures
- Added network reachability check and blocked generation when offline
- Added no-network user message mapping

## v0.5.0-ui-foundation - 2026-02-12
- Added SwiftUI app entry and root tab structure
- Added Home/Search/Review/Settings screens wired to ViewModels
- Added DetailView for entry markdown content
- Added markdown import/export (replace) flow in settings
- Completed UI task checklist for v0.5

## v0.6.0-simulator-build-pass - 2026-02-12
- Added Xcode project bootstrap (EtyNote.xcodeproj)
- Added xcodegen config (project.yml)
- Fixed review notification compile compatibility
- Passed iOS Simulator build on macOS

## v0.7.0-simulator-e2e-pass - 2026-02-12
- Passed full simulator E2E flow: settings save, generate/save, search, detail, delete, review reload
- Added DeepSeek compatibility (endpoint/model auto resolution)
- Improved runtime diagnostics for generation failures (show final concrete error)
- Added simulator fallback for Keychain -34018 and enabled code signing in project config
- Review page now supports tapping a word to open markdown detail
