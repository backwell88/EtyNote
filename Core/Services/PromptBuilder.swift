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
        "Previous JSON invalid. Follow schema strictly.\n\n" + userPrompt(for: word)
    }
}
