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
