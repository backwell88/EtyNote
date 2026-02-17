import Foundation

enum PromptBuilder {
    static let systemPrompt = """
Return only valid JSON.
No explanations.
No markdown.
Do not omit fields.
Do not add fields.
"""

    static func userPrompt(for word: String) -> String {
        """
Analyze the word: \(word)

Rules:
- Return JSON only.
- Keep all keys exactly as schema.
- Every list field must contain at least 1 string item.
- If unknown, use \"N/A\" instead of empty string, null, or missing field.
- root/prefix/suffix must always be objects with form/meaning/originLanguage.

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
"""
    }

    static func retryUserPrompt(for word: String) -> String {
        """
Previous JSON invalid.
Fix and return valid JSON only.
Do not output null.
Do not output empty arrays.
Do not omit fields.

\(userPrompt(for: word))
"""
    }
}
