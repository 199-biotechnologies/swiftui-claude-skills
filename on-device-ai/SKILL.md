---
name: on-device-ai
description: Build iOS 26+ apps with Apple's Foundation Models framework for on-device AI. Use when implementing @Generable structured output, LanguageModelSession, Tool protocol, streaming responses, or any on-device LLM integration. Covers the 3B parameter model available on M1+ devices with Apple Intelligence enabled.
version: 1.0.0
---

# On-Device AI with Foundation Models (iOS 26+)

Build intelligent features using Apple's on-device 3B parameter LLM — free, offline, private.

## Requirements
- iOS 26+ / macOS Tahoe 26+ / iPadOS 26+
- Apple Silicon (M1 or newer)
- Apple Intelligence enabled on device
- `import FoundationModels`

## Core API

### Basic Text Generation
```swift
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "Summarize this article in 3 bullets")
print(response.content) // String
```

### Streaming Responses
```swift
let stream = session.streamResponse(to: "Explain quantum computing")
for try await partial in stream {
    print(partial.content) // Incremental text
}
```

### Structured Output with @Generable
```swift
@Generable
struct RecipeSuggestion {
    var name: String
    var ingredients: [String]
    var cookingTimeMinutes: Int
    var difficulty: Difficulty

    enum Difficulty: String, Generable {
        case easy, medium, hard
    }
}

let session = LanguageModelSession()
let recipe: RecipeSuggestion = try await session.respond(
    to: "Suggest a quick pasta recipe",
    generating: RecipeSuggestion.self
)
```

### Guided Generation with @Guide
```swift
@Guide("Generate a haiku about nature")
struct NatureHaiku {
    @Guide("First line, 5 syllables")
    var line1: String
    @Guide("Second line, 7 syllables")
    var line2: String
    @Guide("Third line, 5 syllables")
    var line3: String
}
```

### Tool Calling
```swift
struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Get current weather for a location"

    struct Input: Codable {
        let location: String
    }

    struct Output: Codable {
        let temperature: Double
        let condition: String
    }

    func call(with input: Input) async throws -> Output {
        // Fetch weather from API
    }
}

let session = LanguageModelSession(tools: [WeatherTool()])
let response = try await session.respond(to: "What's the weather in London?")
```

## Best Practices
- Always check `LanguageModelSession.isAvailable` before use
- Provide fallback UI when model is unavailable (older devices, Intelligence disabled)
- Use `@Generable` for structured output instead of parsing raw text
- Keep prompts concise — 3B model works best with clear, focused instructions
- Use tools for actions that need real data (API calls, database queries)
- Stream responses for better perceived performance on longer outputs

## When NOT to Use
- Complex reasoning tasks (use server-side Claude/GPT instead)
- Tasks requiring internet data (model is offline-only)
- Image/audio generation (this is text-only)
- When user hasn't enabled Apple Intelligence

## Resources
- [Apple: Foundation Models Framework](https://developer.apple.com/documentation/foundationmodels)
- [WWDC25: Bring intelligence to your app](https://developer.apple.com/videos/play/wwdc2025/289/)
- [AppCoda: Foundation Models Tutorial](https://www.appcoda.com/foundation-models/)
