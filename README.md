# SwiftUI Skills for Claude Code

**3 battle-tested Claude Code skills for building world-class iOS 26+ apps with Liquid Glass, animations, and modern SwiftUI patterns.**

Verified against Apple's official WWDC 2025 documentation by a swarm of AI reviewers (Claude Opus 4.6 + GPT-5.4 Codex + Gemini 3.1 Pro).

## The Skills

### `swiftui-liquid-glass` — Liquid Glass API Reference
Everything you need to implement iOS 26's Liquid Glass design language correctly.
- Complete `glassEffect` API with all 3 variants (`.regular`, `.clear`, `.identity`)
- `GlassEffectContainer` morphing, unions, and transitions
- `tabViewBottomAccessory`, sheet morphing, `backgroundExtensionEffect`
- Common mistakes that will get your PR rejected
- Copy-paste snippets that actually compile

### `swiftui-ux-review` — UI/UX Review Engine
Automated review checklist for SwiftUI interfaces. Catches the stuff designers complain about.
- Animation quality audit (springs, timing, accessibility)
- Liquid Glass compliance checker
- iOS 26 new APIs: `@Animatable`, `.symbolEffect(.drawOn/.drawOff)`, `ToolbarSpacer`
- Permission primer patterns (App Store Guideline 5.1.1)
- Accessibility audit: VoiceOver, Dynamic Type, Reduce Motion/Transparency

### `swiftui-ui-patterns` — Component Patterns Library
Production SwiftUI patterns extracted from real shipping apps.
- NavigationStack + Coordinator architecture
- Sheet routing with enum-driven presentation
- Loading states, skeleton views, `ContentUnavailableView`
- Form validation, onboarding flows, card animations
- 26 component references (TabView, ScrollView, Grids, Searchable, etc.)

## What Makes These Different

Most SwiftUI skills are LLM-generated slop with hallucinated APIs. These were:

1. **Cross-verified** by 3 independent AI models against Apple's actual documentation
2. **Bug-fixed** — caught the `.prominent` ghost variant that doesn't exist (it's a button style, not a glass variant)
3. **Complete** — covers iOS 26 APIs that shipped after most training data cutoffs
4. **Practical** — every snippet is a real pattern from shipping apps, not a toy example

## v3.0.0 Changelog (AI-Verified Update)

**Critical fixes:**
- Fixed `.prominent` being listed as a Glass variant (only `.regular`, `.clear`, `.identity` exist)
- `.glassProminent` is a **button style**, not a glass effect variant

**New iOS 26 APIs added:**
- `tabViewBottomAccessory { }` — persistent control above tab bar
- Sheet morphing: `matchedTransitionSource` + `navigationTransition(.zoom)`
- `ToolbarSpacer` — toolbar layout control
- `scrollExtensionMode(.underSidebar)` — content under sidebar
- `backgroundExtensionEffect()` — blur extension for sidebars
- `.symbolEffect(.drawOn/.drawOff)` with `.wholeSymbol`, `.byLayer`, `.individually`
- Rich `TextEditor` with `AttributedString` binding
- Label spacing: `.labelIconToTitleSpacing`, `.labelReservedIconWidth`
- `glassEffectUnion` for merging controls into single glass shape

**Accessibility improvements:**
- Documented that iOS 26 auto-adapts glass for Reduce Transparency
- Added `.identity` variant as manual accessibility fallback

## Installation

Copy the skill folders into your Claude Code skills directory:

```bash
# Clone
git clone https://github.com/199-biotechnologies/swiftui-claude-skills.git

# Copy to Claude Code
cp -r swiftui-claude-skills/swiftui-liquid-glass ~/.claude/skills/
cp -r swiftui-claude-skills/swiftui-ux-review ~/.claude/skills/
cp -r swiftui-claude-skills/swiftui-ui-patterns ~/.claude/skills/
```

## Verified Against

- [Apple: Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC25 Session 219: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 323: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [LiquidGlassReference (Community)](https://github.com/conorluddy/LiquidGlassReference)
- [Hacking with Swift: What's new in SwiftUI for iOS 26](https://www.hackingwithswift.com/articles/278/whats-new-in-swiftui-for-ios-26)
- [Donny Wals: Liquid Glass on iOS 26](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)

## License

MIT
