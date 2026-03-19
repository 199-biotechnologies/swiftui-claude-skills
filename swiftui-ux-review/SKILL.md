---
name: SwiftUI UI/UX Review
description: This skill should be used when the user asks to "review SwiftUI UI", "analyze iOS interface", "check UI/UX patterns", "review liquid glass implementation", "audit SwiftUI accessibility", "check iOS 26 design compliance", "review onboarding flow", "analyze navigation patterns", "review animations", "check animation performance", "audit motion design", "review transitions", "analyze micro-interactions", or mentions SwiftUI design review, UI audit, UX analysis, iOS 26 liquid glass, HIG compliance, accessibility review, animation review, spring animations, keyframe animations, PhaseAnimator, matchedGeometryEffect, haptic feedback, motion design, @Animatable macro, SF Symbols animation, GlassEffectContainer, or symbolEffect for iOS apps.
version: 3.0.0
---

# SwiftUI UI/UX Review Skill

Comprehensive review and analysis of SwiftUI interfaces for iOS 17/18/26+ with focus on **animations**, Liquid Glass design language, Apple Human Interface Guidelines (HIG), accessibility standards, and modern UI/UX patterns.

## When to Use This Skill

- **Reviewing animations** - springs, keyframes, transitions, micro-interactions, liquid glass morphing
- Reviewing SwiftUI code for UI/UX best practices
- Auditing compliance with iOS 26 Liquid Glass design language
- Checking accessibility implementation (VoiceOver, Dynamic Type, Reduce Motion)
- Analyzing navigation, onboarding, tabs, sheets, and modal patterns
- Identifying common UI/UX mistakes and anti-patterns
- Evaluating animation performance and timing
- Providing actionable recommendations for interface improvements

## Review Process

### Step 1: Gather Context

Before reviewing, collect information about:
1. **Target iOS version** - iOS 17+ for PhaseAnimator/KeyframeAnimator; iOS 26+ for Liquid Glass
2. **App purpose** - Different apps require different animation intensities
3. **User demographics** - Accessibility requirements vary by audience
4. **Existing design system** - Check for design tokens and theming

### Step 2: Structural Analysis

Analyze the SwiftUI code structure for:

| Component | Check For |
|-----------|-----------|
| Navigation | NavigationStack usage, tab bar implementation, deep linking support |
| State Management | @State, @Binding, @Observable patterns, data flow |
| View Hierarchy | Proper component decomposition, reusability |
| Modifiers | Correct modifier ordering, accessibility modifiers |
| **Animations** | Spring parameters, timing, transitions, accessibility compliance |

### Step 3: Animation Review (NEW)

#### Animation Quality Checklist

| Aspect | Standard | Check For |
|--------|----------|-----------|
| **Timing** | 100-500ms | Animations not too fast or slow |
| **Springs** | Used for interactive | `response`, `dampingFraction` appropriate |
| **Purpose** | Communicates change | Not gratuitous or distracting |
| **Performance** | No frame drops | `drawingGroup()` for complex views |
| **Accessibility** | Respects settings | Checks `accessibilityReduceMotion` |

#### Spring Animation Standards

**Recommended Springs:**
```swift
// Button press - quick, bouncy
.spring(response: 0.3, dampingFraction: 0.6)

// Modal presentation - smooth, natural
.spring(response: 0.5, dampingFraction: 0.8)

// Card expansion - elegant, controlled
.spring(response: 0.6, dampingFraction: 0.85)

// Subtle hover - minimal, fast
.spring(response: 0.2, dampingFraction: 0.9)
```

**iOS 17+ Presets:**
- `.bouncy` - High bounce, playful
- `.smooth` - No overshoot, professional
- `.snappy` - Quick response

**iOS 26+ New APIs (WWDC 2025):**
- `@Animatable` macro - Auto-synthesizes `Animatable` conformance for Shapes
- `@AnimatableIgnored` macro - Excludes properties from animation interpolation
- `.symbolEffect(.drawOn)` / `.symbolEffect(.drawOff)` - SF Symbols 7 stroke-based reveal/dismiss animations (supports `.wholeSymbol`, `.byLayer`, `.individually`)
- `.backgroundExtensionEffect()` - Blur extension beyond view bounds (for sidebars, inspectors)
- `tabViewBottomAccessory { }` - Persistent control above tab bar (gets glass capsule automatically)
- `ToolbarSpacer` - Control spacing between toolbar items
- `scrollExtensionMode(.underSidebar)` - Extend scroll content under sidebar
- Sheet morphing: `matchedTransitionSource(id:in:)` + `navigationTransition(.zoom(sourceID:in:))`
- Rich `TextEditor` with `AttributedString` binding and `onSelectionChange`
- Label spacing: `.labelIconToTitleSpacing`, `.labelReservedIconWidth`

#### Common Animation Issues

| Issue | Severity | Solution |
|-------|----------|----------|
| `.animation()` without value | High | Use `.animation(_:value:)` |
| Linear timing for UI | Medium | Use springs for natural feel |
| No `reduceMotion` check | High | Add `@Environment(\.accessibilityReduceMotion)` |
| Heavy views in keyframes | High | Use `drawingGroup()` |
| Multiple conflicting `withAnimation` | Medium | Consolidate into single block |
| Animation during scroll | Medium | Defer until scroll ends |

#### Transition Review

**Check transitions use:**
- `.asymmetric(insertion:removal:)` for directional animations
- `.combined(with:)` for multi-property transitions
- Appropriate timing that matches gesture direction

#### Micro-Interactions

**Verify:**
- Button press has visual feedback (scale, opacity)
- Haptic feedback matches action type (`.success`, `.error`, `.selection`)
- Feedback not excessive or annoying

### Step 4: Liquid Glass Compliance (iOS 26+)

**Glass Variants (IMPORTANT — only 3 exist):**

| Variant | Use Case |
|---------|----------|
| `.regular` | Standard navigation elements, toolbars, tabs |
| `.clear` | Subtle controls over media-rich backgrounds |
| `.identity` | No effect — for conditional toggling / accessibility |

**WARNING:** `.prominent` is NOT a glass variant. Use `.buttonStyle(.glassProminent)` for prominent buttons.

**Appropriate Uses:**
- Navigation bars and toolbars
- Tab bars and bottom accessories (use `tabViewBottomAccessory` for floating bars)
- Floating action buttons
- Sheets, popovers, and menus (system applies glass automatically in iOS 26)
- Context-sensitive controls
- `ToolbarSpacer` for grouping toolbar items

**Avoid Liquid Glass For:**
- Content layer (lists, tables, media)
- Full-screen backgrounds
- Scrollable content
- Stacked glass layers (glass cannot sample other glass)
- Custom shadows/borders (trust system edge effects)

**Glass Morphing Animations:**
- Use `GlassEffectContainer` for coordinated morphing
- Apply `glassEffectID(_:in:)` for morph coordination
- Use `glassEffectUnion(id:namespace:)` to merge related controls into one glass shape
- Use `.bouncy` animation for glass transitions
- Wrap state changes in `withAnimation(.bouncy)`
- Don't use `presentationBackground()` on sheets — system handles it

**New iOS 26 Layout APIs:**
- `tabViewBottomAccessory { }` — persistent control above tab bar (like Now Playing)
- `ToolbarSpacer` — control spacing between toolbar items
- `scrollExtensionMode(.underSidebar)` — extend scroll content under sidebar
- `backgroundExtensionEffect()` — extend/blur content behind sidebars
- Sheet morphing: `matchedTransitionSource(id:in:)` + `navigationTransition(.zoom(sourceID:in:))`

Check for proper `.glassEffect()` usage with `#available(iOS 26.0, *)` guards.

### Step 5: Pattern Validation

#### Onboarding Patterns
- **iOS 18+**: Prefer ScrollView with `scrollTargetBehavior(.viewAligned)` over TabView
- Use `@AppStorage` for tracking completion state
- Present using `.fullScreenCover` for immersive experience
- Include skip option and progress indicators
- **Animations**: Staggered entry with `.delay()`, parallax effects

#### Tab Navigation
- Each tab maintains its own NavigationStack
- State preserved when switching tabs
- Coordinator pattern for complex flows
- iOS 26: Tabs auto-shrink on scroll
- **Animations**: `matchedGeometryEffect` for tab indicator

#### Sheets and Modals
- Attach `.sheet` to outermost container view
- Use `presentationDetents` for height control (iOS 16+)
- `interactiveDismissDisabled()` when dismissal must be controlled
- Forms for settings/profiles, fullScreenCover for immersive content
- **Animations**: Spring presentation with `response: 0.5, dampingFraction: 0.8`

#### Loading States
- Use `.redacted(reason: .placeholder)` for skeleton views
- Model states with enum (loading, loaded, empty, error)
- ContentUnavailableView for empty states (iOS 17+)
- `.unredacted()` for fixed elements during loading
- **Animations**: Shimmer effect with repeating linear gradient

#### Counter/Numeric Displays
- Use `.contentTransition(.numericText())` for animated counters
- Combine with `.sensoryFeedback(.increase, trigger:)` for haptics

#### Permission Request Patterns (App Store Guideline 5.1.1)

**Critical:** Permission primers (custom alerts before iOS permission dialogs) must NOT have exit/dismiss buttons.

**Compliant Pattern:**
```swift
// OK: Primer with only "Continue" - user must proceed to iOS dialog
.alert("Camera Access", isPresented: $showPrimer) {
    Button("Continue") { requestCameraPermission() }
} message: {
    Text("We need camera access to scan documents.")
}
```

**Non-Compliant Pattern (App Store Rejection):**
```swift
// REJECTED: "Not Now" lets user skip the iOS permission dialog
.alert("Camera Access", isPresented: $showPrimer) {
    Button("Continue") { requestCameraPermission() }
    Button("Not Now", role: .cancel) { dismiss() }  // ← VIOLATION
} message: {
    Text("We need camera access to scan documents.")
}
```

**Best Practices:**
- If showing a primer, user MUST proceed to the actual iOS permission dialog
- No "Skip", "Not Now", "Later", or "Cancel" buttons on pre-permission primers
- After denial, you CAN show an alert with "Open Settings" + "Cancel"
- Consider skipping primers entirely - iOS dialogs show your Info.plist usage descriptions
- Request permissions contextually (when user tries to use the feature), not on app launch

**Applies to:** Camera, Microphone, Photos, Location, Contacts, Calendars, Speech Recognition, Health, Motion, Bluetooth, Local Network, Tracking (ATT)

### Step 6: Accessibility Audit

**Required Checks:**

| Modifier | Purpose |
|----------|---------|
| `.accessibilityLabel()` | Descriptive label for VoiceOver |
| `.accessibilityHint()` | Action context for users |
| `.accessibilityElement(children:)` | Group related elements |
| `.accessibilityHidden()` | Hide decorative elements |

**Dynamic Type:** Verify text scales with system settings. Avoid fixed font sizes.

**Reduce Transparency:** Check `@Environment(\.accessibilityReduceTransparency)` for Liquid Glass fallbacks.

**Reduce Motion:** Check `@Environment(\.accessibilityReduceMotion)` and disable/simplify animations.

**Color Contrast:** Use `.primary`, `.secondary` over hardcoded colors.

### Step 7: Generate Report

Structure findings as:

```markdown
## UI/UX Review Summary

### Strengths
- [List positive patterns found]

### Animation Issues
1. **[Issue Name]** - Severity: High/Medium/Low
   - Location: `FileName.swift:LineNumber`
   - Problem: [Description]
   - Recommendation: [Specific fix with code]

### UI/UX Issues
1. **[Issue Name]** - Severity: High/Medium/Low
   - Location: `FileName.swift:LineNumber`
   - Problem: [Description]
   - Recommendation: [Specific fix]

### Recommendations
- [Prioritized list of improvements]

### Code Examples
- [Before/after code snippets]
```

## Quick Reference: Common Issues

| Issue | Severity | Solution |
|-------|----------|----------|
| Permission primer with exit button | **Critical** | Remove "Not Now"/"Skip" - user must proceed to iOS dialog (Guideline 5.1.1) |
| Liquid Glass on content layer | High | Move to navigation layer only |
| Missing accessibility labels | High | Add `.accessibilityLabel()` to interactive elements |
| No `reduceMotion` check | High | Add environment check, simplify animations |
| `.animation()` without value | High | Use `.animation(_:value:)` |
| Fixed font sizes | Medium | Use system semantic fonts |
| Stacked glass layers | Medium | Reduce glass layers, add spacing |
| Linear animation for buttons | Medium | Use spring with `dampingFraction: 0.6-0.8` |
| No haptic feedback | Low | Add `.sensoryFeedback()` for important actions |
| TabView for iOS 18+ onboarding | Low | Migrate to ScrollView pattern |
| Sheet attached to button | Low | Move to container view |

## Animation API Quick Reference

### iOS 17+ Animators

```swift
// PhaseAnimator - Multi-step cycling
PhaseAnimator([Phase.a, .b, .c], trigger: value) { phase in
    Content().modifier(for: phase)
} animation: { phase in
    .spring(response: 0.3)
}

// KeyframeAnimator - Fine-grained control
.keyframeAnimator(initialValue: Values(), trigger: trigger) { content, value in
    content.scaleEffect(value.scale)
} keyframes: { _ in
    KeyframeTrack(\.scale) {
        SpringKeyframe(1.2, duration: 0.2)
        SpringKeyframe(1.0, duration: 0.3)
    }
}
```

### Transitions

```swift
// Combined transition
.transition(.move(edge: .bottom).combined(with: .opacity))

// Asymmetric
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .move(edge: .leading)
))

// iOS 17+
.transition(.blurReplace)
.transition(.push(from: .bottom))
```

### Haptic Feedback (iOS 17+)

```swift
.sensoryFeedback(.success, trigger: value)
.sensoryFeedback(.selection, trigger: selection)
.sensoryFeedback(.impact, trigger: collision)
```

## Design Tokens Reference

Recommended spacing scale:
- `xs`: 4pt, `sm`: 8pt, `md`: 16pt, `lg`: 24pt, `xl`: 32pt

Use semantic colors:
- `.primary`, `.secondary` for text
- `.background`, `.secondaryBackground` for surfaces
- System tints for interactive elements

## Additional Resources

### Reference Files

For detailed patterns and guidelines, consult:
- **`references/animation-guide.md`** - Comprehensive animation reference with springs, keyframes, transitions, micro-interactions, and performance optimization
- **`references/liquid-glass-guide.md`** - Complete iOS 26 Liquid Glass implementation guide with code examples
- **`references/ui-patterns.md`** - Detailed SwiftUI patterns for navigation, onboarding, forms, loading states
- **`references/accessibility-checklist.md`** - Complete VoiceOver, Dynamic Type, Reduce Motion audit checklist with testing procedures

### External Resources

**Apple Official:**
- [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Animating views and transitions](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC23: Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)
- [WWDC18: Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/)
- [WWDC25: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)

**Animation Libraries:**
- [Pow](https://github.com/EmergeTools/Pow) - Delightful SwiftUI effects (Spray, Shake, Shine, Jump, Rise, Spin)
- [AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - Preset tab bar animations
- [open-swiftui-animations](https://github.com/amosgyamfi/open-swiftui-animations) - Loading, looping, spring examples
- [Hero](https://github.com/HeroTransitions/Hero) - Elegant transition library
- [FlowStack](https://github.com/velos/FlowStack) - Hero animations with NavigationStack API
- [SkeletonUI](https://github.com/CSolanaM/SkeletonUI) - Elegant skeleton loading

**Hero Transitions:**
- [swiftui-hero-animations](https://github.com/swiftui-lab/swiftui-hero-animations) - matchedGeometryEffect examples
- [swiftui-hero-animations-no-transitions](https://github.com/swiftui-lab/swiftui-hero-animations-no-transitions) - Morphing without transitions

**Liquid Glass & iOS 26:**
- [iOS-26-by-Examples](https://github.com/artemnovichkov/iOS-26-by-Examples) - Comprehensive iOS 26 feature examples
- [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference) - Ultimate Swift/SwiftUI reference
- [LiquidGlassSwiftUI](https://github.com/mertozseven/LiquidGlassSwiftUI) - Sample Liquid Glass app

**Tutorials:**
- [SwiftUI Lab - PhaseAnimator](https://swiftui-lab.com/swiftui-animations-part7/)
- [AppCoda - KeyframeAnimator](https://www.appcoda.com/keyframeanimator/)
- [Hacking with Swift - Spring Animations](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-spring-animation)
- [Design+Code - Phase Animator](https://designcode.io/swiftui-handbook-phase-animator/)
- [Jacob's Tech Tavern - Keyframe Animations](https://blog.jacobstechtavern.com/p/swiftui-keyframe-animations)
