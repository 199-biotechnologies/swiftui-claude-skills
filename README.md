# iOS & macOS 26 Skills for Claude Code

**8 production-grade Claude Code skills for building world-class iOS 26 / macOS Tahoe apps.**

Verified against Apple's WWDC 2025 docs + Xcode 26.3 (latest as of March 2026) by a swarm of AI (Claude Opus 4.6 + GPT-5.4 Codex + Gemini 3.1 Pro). Current through iOS 26.4 RC / macOS 26.4 RC (March 18, 2026).

## The Skills

### Custom Skills (by 199 Biotechnologies)

| Skill | What It Does |
|-------|-------------|
| **`swiftui-liquid-glass`** | Complete Liquid Glass API — all 3 variants, morphing, unions, `tabViewBottomAccessory`, sheet morphing, common mistakes |
| **`swiftui-ux-review`** | Automated UI/UX review engine — animations, accessibility, HIG compliance, permission primers, iOS 26 new APIs |
| **`swiftui-ui-patterns`** | 26 component references — NavigationStack, sheets, forms, loading states, cards, 26+ reference files |
| **`on-device-ai`** | Foundation Models framework — `@Generable`, `LanguageModelSession`, Tool protocol, streaming, structured output |

### Included: Paul Hudson's Pro Skills (twostraws)

| Skill | What It Does |
|-------|-------------|
| **`swiftui-pro`** | Comprehensive SwiftUI code review — modern APIs, deprecated detection, performance, VoiceOver, HIG |
| **`swift-testing-pro`** | Swift Testing framework — `@Test` macro, common LLM mistakes, smaller/faster patterns |
| **`swift-concurrency-pro`** | Swift 6.2 concurrency — `@concurrent`, actors, `Sendable`, async/await pitfalls |
| **`swiftdata-pro`** | SwiftData — modeling, queries, relationships, migrations, model inheritance |

## Why These Exist

Most "SwiftUI skills" floating around have hallucinated APIs. We caught these in the wild:
- `.prominent` listed as a Glass variant (doesn't exist — only `.regular`, `.clear`, `.identity`)
- `ObservableObject` recommended over `@Observable` (deprecated pattern)
- Missing 10+ iOS 26 APIs that shipped after training cutoffs

These skills were cross-verified by 3 independent AI models against Apple's actual documentation. Every snippet compiles.

## Quick Install

```bash
git clone https://github.com/199-biotechnologies/swiftui-claude-skills.git
cp -r swiftui-claude-skills/*-pro swiftui-claude-skills/swiftui-* swiftui-claude-skills/on-device-ai ~/.claude/skills/
```

## What's Covered

### Liquid Glass (iOS 26)
`glassEffect` variants, `GlassEffectContainer`, `glassEffectUnion`, `glassEffectID` morphing, `buttonStyle(.glass/.glassProminent)`, `tabViewBottomAccessory`, sheet morphing, `backgroundExtensionEffect`, `scrollExtensionMode`, accessibility auto-adaptation

### Animations
Spring presets (`.bouncy`/`.smooth`/`.snappy`), `PhaseAnimator`, `KeyframeAnimator`, `matchedGeometryEffect`, `@Animatable`/`@AnimatableIgnored` macros, SF Symbols 7 `.drawOn`/`.drawOff`, haptic feedback, performance optimization

### SwiftUI Patterns
NavigationStack + Coordinator, enum-driven sheets, `ContentUnavailableView`, skeleton loading, form validation, onboarding flows, card animations, `WebView`/`WebPage`, rich `TextEditor` with `AttributedString`

### On-Device AI
Foundation Models `LanguageModelSession`, `@Generable` structured output, `@Guide` annotations, Tool protocol for function calling, streaming responses

### Swift 6.2 Concurrency
`@concurrent`, `nonisolated(nonsending)`, default `@MainActor` isolation, `Task.immediate`, actor-isolated protocol conformances

### Testing
`@Test` macro, `#expect`, parameterized tests, exit tests, attachments, Swift Testing best practices

### SwiftData
`@Model`, `@Query`, model inheritance (iOS 26), relationships, migrations, `FetchDescriptor`

## Also Recommended (Not Included)

Install these separately for the full iOS dev experience:

| Tool | What | Install |
|------|------|---------|
| [XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) | Build/test/archive from Claude (4.6k stars) | `brew install xcodebuildmcp` |
| [apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp) | Search Apple docs live | MCP server |
| [Axiom](https://github.com/CharlesWiltgen/Axiom) | Xcode debugging, compiler diagnostics | Skills bundle |

## Verified Against

- [Apple: Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC25 Session 219: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 323: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Hacking with Swift: What's new in SwiftUI for iOS 26](https://www.hackingwithswift.com/articles/278/whats-new-in-swiftui-for-ios-26)
- [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference)
- [Donny Wals: Liquid Glass](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)
- [Swift 6.2 Released](https://www.swift.org/blog/swift-6.2-released/)

## Credits

- Custom skills by [199 Biotechnologies](https://github.com/199-biotechnologies)
- Pro skills by [Paul Hudson / twostraws](https://github.com/twostraws) (MIT License)
- Verified using Claude Opus 4.6, GPT-5.4 Codex, Gemini 3.1 Pro

## License

MIT
