# EtyNote iOS Engineering Specification

Version 3.0  
Architecture: Local-first JSON → Validation → Markdown

---

# 1. Overview

EtyNote is a local-first iOS app for English etymology lookup.

Core workflow:

Input → AI returns JSON → Validate JSON → Convert to Markdown → Append to local file → Update index → Enable search & random review.

No cloud.  
No login.  
No server storage.  
Network required only during AI generation.

---

# 2. Technical Stack

- Swift 5.9+
    
- SwiftUI
    
- async/await
    
- Keychain (API key storage)
    
- Local Markdown file
    
- UNUserNotificationCenter (daily review)
    

---

# 3. Project Structure

```
EtyNote/
│
├── App/
│   └── EtyNoteApp.swift
│
├── Core/
│   ├── Models/
│   │   ├── WordEntry.swift
│   │   └── Morphology.swift
│   │
│   ├── Services/
│   │   ├── AIService.swift
│   │   ├── DictionaryService.swift
│   │   ├── MarkdownService.swift
│   │   ├── FileService.swift
│   │   ├── IndexService.swift
│   │   └── KeychainService.swift
│   │
│   ├── Validation/
│   │   └── JSONValidator.swift
│   │
│   └── Review/
│       └── ReviewManager.swift
│
├── Features/
│   ├── Home/
│   ├── Search/
│   ├── Detail/
│   └── Settings/
│
└── Resources/

```
---

# 4. Data Models

## WordEntry.swift

```
struct WordEntry: Codable {
    let word: String
    let partOfSpeech: [String]
    let englishMeaning: [String]
    let chineseMeaning: [String]
    let root: Morphology
    let prefix: Morphology
    let suffix: Morphology
    let relatedWords: [String]
    let variants: [String]
}

```

## Morphology.swift

```
struct Morphology: Codable {
    let form: String
    let meaning: String
    let originLanguage: String
}

```
Rules:

- All fields must exist
    
- Arrays must contain at least one string
    
- No extra fields allowed
    

---

# 5. AI API Protocol

## System Prompt

Return only valid JSON.  
No explanations.  
No markdown.  
Do not omit fields.  
Do not add fields.

## User Prompt Template

```
Analyze the word: {word}

Return strictly in this JSON format:

{
  "word": "",
  "partOfSpeech": [""],
  "englishMeaning": [""],
  "chineseMeaning": [""],
  "root": {
    "form": "",
    "meaning": "",
    "originLanguage": ""
  },
  "prefix": {
    "form": "",
    "meaning": "",
    "originLanguage": ""
  },
  "suffix": {
    "form": "",
    "meaning": "",
    "originLanguage": ""
  },
  "relatedWords": [""],
  "variants": [""]
}

```

Temperature: 0.2  
Retry limit: 3

---

# 6. JSON Validation Flow

1. Decode using Codable
    
2. If decode fails → retry
    
3. Validate non-empty arrays
    
4. Ensure no nil values
    
5. After 3 failures → show error
    

On second retry prepend:

“Previous JSON invalid. Follow schema strictly.”

---

# 7. Markdown Conversion

Client generates Markdown.

Template:

```
---

# {word}

## Part of Speech
- verb

## English Meaning
- to build

## Chinese Meaning
- 建造

## Root
- Form: struct
- Meaning: to build
- Origin: Latin

## Prefix
- Form: con-
- Meaning: together
- Origin: Latin

## Suffix
- Form:
- Meaning:
- Origin:

## Related Words
- structure

## Variants
- construction

---

```

No deviation allowed.

---

# 8. Local File Rules

Path:

Documents/EtyNote/etynote.md

Append only.

Deletion:  
Remove block between separators containing matching "# word".

Search:

- Case insensitive
    
- Substring match
    
- Title only
    

---

# 9. Chinese Input Flow

If input contains Chinese characters:

1. Call DictionaryService
    
2. Return most common English equivalent
    
3. Pass to AI pipeline
    

If no match → show error

---

# 10. Review System

Daily 07:00 notification.

On app open:

1. Load title index
    
2. Shuffle
    
3. Take first N
    
4. Display swipe cards
    

No memory tracking.

---

# 11. Settings

- API Key input
    
- BaseURL input
    
- Test connection
    
- Daily review count
    
- Enable/disable review
    
- Import Markdown (replace)
    
- Export Markdown
    
- Dark mode toggle
    

API Key stored using Keychain only.

---

# 12. Example JSON

```
{
  "word": "construct",
  "partOfSpeech": ["verb"],
  "englishMeaning": ["to build"],
  "chineseMeaning": ["建造"],
  "root": {
    "form": "struct",
    "meaning": "to build",
    "originLanguage": "Latin"
  },
  "prefix": {
    "form": "con-",
    "meaning": "together",
    "originLanguage": "Latin"
  },
  "suffix": {
    "form": "",
    "meaning": "",
    "originLanguage": ""
  },
  "relatedWords": ["structure"],
  "variants": ["construction"]
}

```

---

# 13. Error Handling

- No network → block generation
    
- Timeout >15s → cancel
    
- Invalid JSON → retry
    
- File write failure → alert
    
- Empty API key → block call
    

---

# 14. Non Goals

- No cloud sync
    
- No login
    
- No spaced repetition
    
- No analytics
    
- No backend server