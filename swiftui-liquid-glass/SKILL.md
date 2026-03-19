---
name: swiftui-liquid-glass
description: Implement, review, or improve SwiftUI features using the iOS 26+ Liquid Glass API. Use when asked to adopt Liquid Glass in new SwiftUI UI, refactor an existing feature to Liquid Glass, or review Liquid Glass usage for correctness, performance, and design alignment.
version: 3.0.0
---

# SwiftUI Liquid Glass

## Overview
Use this skill to build or review SwiftUI features that fully align with the iOS 26+ Liquid Glass API. Prioritize native APIs (`glassEffect`, `GlassEffectContainer`, glass button styles) and Apple design guidance. Keep usage consistent, interactive where needed, and performance aware.

## Glass API Reference

### Core Modifier
```swift
func glassEffect<S: Shape>(
    _ glass: Glass = .regular,
    in shape: S = DefaultGlassEffectShape,  // capsule
    isEnabled: Bool = true
) -> some View
```

### Glass Variants (IMPORTANT: Only 3 exist)

| Variant | Use Case |
|---------|----------|
| `.regular` | Standard navigation elements, toolbars, tabs |
| `.clear` | Subtle floating controls over media-rich backgrounds |
| `.identity` | No effect — used for conditional toggling (e.g., accessibility) |

**WARNING:** There is NO `.prominent` variant. For prominent styling, use `.buttonStyle(.glassProminent)` on buttons only.

### Shapes
- `.capsule` (default)
- `.circle`
- `.ellipse`
- `.rect(cornerRadius:)` — supports `.containerConcentric` for auto-matching parent corners
- Any custom `Shape` conforming type

### Tinting
```swift
.glassEffect(.regular.tint(.blue))
.glassEffect(.regular.tint(.purple.opacity(0.6)))
```

### Interactivity (iOS only)
```swift
.glassEffect(.regular.interactive())
```
Enables: scaling, bouncing, shimmering, touch-point illumination, gesture response.

## Workflow Decision Tree
Choose the path that matches the request:

### 1) Review an existing feature
- Inspect where Liquid Glass should be used and where it should not.
- Verify correct modifier order, shape usage, and container placement.
- Check for iOS 26+ availability handling and sensible fallbacks.
- Verify NO `.prominent` variant used (only `.regular`, `.clear`, `.identity`).

### 2) Improve a feature using Liquid Glass
- Identify target components for glass treatment (surfaces, chips, buttons, cards).
- Refactor to use `GlassEffectContainer` where multiple glass elements appear.
- Introduce interactive glass only for tappable or focusable elements.
- Use `glassEffectUnion` to visually merge related controls (like Apple Maps zoom controls).

### 3) Implement a new feature using Liquid Glass
- Design the glass surfaces and interactions first (shape, variant, grouping).
- Add glass modifiers after layout/appearance modifiers.
- Add morphing transitions only when the view hierarchy changes with animation.
- Use `tabViewBottomAccessory` for persistent controls above tab bar.

## Core Guidelines
- Prefer native Liquid Glass APIs over custom blurs.
- Use `GlassEffectContainer` when multiple glass elements coexist.
- Apply `.glassEffect(...)` after layout and visual modifiers.
- Use `.interactive()` for elements that respond to touch/pointer.
- Keep shapes consistent across related elements for a cohesive look.
- Gate with `#available(iOS 26, *)` and provide a non-glass fallback.
- Glass cannot sample other glass — use containers, never stack glass layers.
- Text on glass receives automatic vibrant treatment with contrast adjustment.
- Do NOT add custom shadows or borders — the system handles edge effects.

## Review Checklist
- **Availability**: `#available(iOS 26, *)` present with fallback UI.
- **Variants**: Only `.regular`, `.clear`, `.identity` used (NOT `.prominent`).
- **Composition**: Multiple glass views wrapped in `GlassEffectContainer`.
- **Modifier order**: `glassEffect` applied after layout/appearance modifiers.
- **Interactivity**: `interactive()` only where user interaction exists.
- **Transitions**: `glassEffectID` used with `@Namespace` for morphing.
- **Unions**: Related controls grouped with `glassEffectUnion`.
- **Consistency**: Shapes, tinting, and spacing align across the feature.
- **No manual shadows/borders**: Trust the system edge effects.
- **Accessibility**: System auto-adapts for Reduce Transparency; use `.identity` as manual fallback.

## Implementation Checklist
- Define target elements and desired glass variant (`.regular` for most, `.clear` for media overlays).
- Wrap grouped glass elements in `GlassEffectContainer` and tune spacing.
- Use `.glassEffect(.regular.tint(...).interactive(), in: .rect(cornerRadius: ...))` as needed.
- Use `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` for actions.
- Use `glassEffectUnion(id:namespace:)` to merge related controls into one glass shape.
- Add morphing transitions with `glassEffectID` when hierarchy changes.
- Provide fallback materials and visuals for earlier iOS versions.
- Use `tabViewBottomAccessory` for persistent floating controls (like Now Playing).

## Quick Snippets

### Basic Glass with Fallback
```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

### Container with Multiple Elements
```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
    }
}
```

### Glass Buttons
```swift
Button("Confirm") { }
    .buttonStyle(.glassProminent)

Button("Cancel") { }
    .buttonStyle(.glass)
```

### Union — Merge Controls into One Glass Shape
```swift
@Namespace private var ns

GlassEffectContainer(spacing: 20) {
    HStack(spacing: 20) {
        Button("+") { }.glassEffect()
            .glassEffectUnion(id: "zoom", namespace: ns)
        Button("-") { }.glassEffect()
            .glassEffectUnion(id: "zoom", namespace: ns)
    }
}
```

### Morphing Transition
```swift
@Namespace private var ns
@State private var expanded = false

GlassEffectContainer {
    if expanded {
        ExpandedToolbar()
            .glassEffect()
            .glassEffectID("toolbar", in: ns)
    } else {
        CompactFAB()
            .glassEffect()
            .glassEffectID("toolbar", in: ns)
    }
}
.onTapGesture {
    withAnimation(.bouncy) { expanded.toggle() }
}
```

### Tab Bar Bottom Accessory (iOS 26)
```swift
TabView {
    HomeView().tabItem { Label("Home", systemImage: "house") }
}
.tabViewBottomAccessory {
    NowPlayingBar()  // Gets glass capsule automatically
}
```

### Sheet Morphing from Toolbar (iOS 26)
```swift
@Namespace private var ns

.toolbar {
    ToolbarItem {
        Button("Add") { showSheet = true }
            .matchedTransitionSource(id: "add", in: ns)
    }
}
.sheet(isPresented: $showSheet) {
    AddItemView()
        .navigationTransition(.zoom(sourceID: "add", in: ns))
}
```

### Sidebar Background Extension
```swift
NavigationSplitView {
    SidebarContent()
} detail: {
    DetailContent()
        .background {
            Image("hero").backgroundExtensionEffect()
        }
}
```

### Scroll Extension Under Sidebar
```swift
ScrollView(.horizontal) {
    // Content extends under sidebar
}
.scrollExtensionMode(.underSidebar)
```

### Accessibility-Aware Glass
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

// iOS 26 auto-adapts: increases frosting, adds stark colors/borders
// Manual override only when needed:
.glassEffect(reduceTransparency ? .identity : .regular)
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `.prominent` as Glass variant | Use `.regular` or `.clear`. `.glassProminent` is button-style only |
| Glass on list items/content | Glass is navigation layer only |
| Stacking glass layers | Use `GlassEffectContainer`, never nest glass |
| Custom shadows/borders on glass | Trust system edge effects |
| Missing `#available` guard | Always gate with `#available(iOS 26, *)` |
| Manual Reduce Transparency handling | System auto-adapts; `.identity` for full disable |
| `presentationBackground()` on sheets | System applies glass automatically in iOS 26 |

## Resources
- Reference guide: `references/liquid-glass.md`
- [Apple: Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC25 Session 219: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 323: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [LiquidGlassReference (Community)](https://github.com/conorluddy/LiquidGlassReference)
- [Donny Wals: Designing custom UI with Liquid Glass](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)
