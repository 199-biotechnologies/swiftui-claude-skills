# iOS 26 Liquid Glass Complete Implementation Guide

## Overview

Liquid Glass is Apple's most significant design evolution since iOS 7, introduced at WWDC 2025. It's a translucent, dynamic material that reflects and refracts surrounding content while transforming to bring focus to user tasks.

**Key Characteristics:**
- Real-time light bending (lensing)
- Specular highlights responding to device motion
- Adaptive shadows
- Interactive behaviors
- Unified across iOS 26, iPadOS 26, macOS Tahoe 26, watchOS 26, tvOS 26, visionOS 26

## Design Philosophy

### Core Principle: Navigation Layer Only

Liquid Glass is **exclusively** for the navigation layer that floats above app content. Never apply to content itself.

```
┌─────────────────────────────────┐
│      🔲 Liquid Glass Layer      │  ← Navigation, toolbars, tabs
├─────────────────────────────────┤
│                                 │
│         Content Layer           │  ← Lists, tables, media (NO glass)
│                                 │
└─────────────────────────────────┘
```

### Hierarchy Principle

Content sits at the bottom, glass controls float on top. This maintains clear visual hierarchy where content remains primary while controls provide functional overlay.

## SwiftUI Implementation

### Basic Glass Effect

```swift
import SwiftUI

struct GlassButton: View {
    var body: some View {
        Button("Action") {
            // action
        }
        .padding()
        .glassEffect()  // Default capsule shape
    }
}
```

### Custom Shape Glass

```swift
struct RoundedGlassCard: View {
    var body: some View {
        VStack {
            Text("Title")
            Text("Content")
        }
        .padding()
        .glassEffect(.regular.shape(RoundedRectangle(cornerRadius: 16)))
    }
}
```

### Glass Effect Variants

| Variant | Use Case |
|---------|----------|
| `.regular` | Standard navigation elements, toolbars, tabs |
| `.clear` | Subtle floating controls over media-rich backgrounds |
| `.identity` | No effect — conditional toggle for accessibility |

**WARNING:** There is NO `.prominent` glass variant. For prominent actions, use `.buttonStyle(.glassProminent)` on buttons.

### Tinted Glass

```swift
Button("Important") {
    // action
}
.tint(.blue)
.glassEffect()
```

### Version Gating (Critical)

Always gate Liquid Glass behind availability checks:

```swift
struct AdaptiveNavBar: View {
    var body: some View {
        HStack {
            // Navigation content
        }
        .modifier(GlassEffectModifier())
    }
}

struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect()
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

## Glass Coherence with GlassEffectContainer

Coordinate multiple glass elements to morph into each other:

```swift
struct CoherentToolbar: View {
    @Namespace private var glassNamespace

    var body: some View {
        GlassEffectContainer {
            HStack {
                Button("Edit") { }
                    .glassEffectID("edit", in: glassNamespace)

                Button("Share") { }
                    .glassEffectID("share", in: glassNamespace)

                Button("Delete") { }
                    .glassEffectID("delete", in: glassNamespace)
            }
        }
    }
}
```

## Corner Concentricity

Maintain visual harmony by aligning corner radii:

```swift
struct ConcentricSheet: View {
    var body: some View {
        VStack {
            // Sheet content

            Button("Confirm") { }
                .padding()
                .background {
                    // Uses concentric rectangle to match sheet corners
                    ConcentricRectangle()
                        .fill(.ultraThinMaterial)
                }
        }
        .padding()
    }
}
```

## Tab Bar Behavior (iOS 26)

Tab bars automatically shrink when users scroll, expanding when scrolling back up:

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        // No additional configuration needed - shrink behavior is automatic
    }
}
```

## Common Mistakes and Solutions

### Mistake 1: Glass on Content

❌ **Wrong:**
```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .glassEffect()  // DON'T apply glass to list items
    }
}
```

✅ **Correct:**
```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
        // Content uses standard styling, no glass
    }
}
.toolbar {
    ToolbarItem {
        Button("Add") { }
            .glassEffect()  // Glass only on floating controls
    }
}
```

### Mistake 2: Stacked Glass Layers

❌ **Wrong:**
```swift
ZStack {
    ContentView()

    VStack {
        CardView()
            .glassEffect()  // Glass layer 1

        Sheet {
            DetailView()
                .glassEffect()  // Glass layer 2 - blur pile!
        }
    }
    .glassEffect()  // Glass layer 3 - too much!
}
```

✅ **Correct:**
```swift
ZStack {
    ContentView()

    VStack(spacing: 24) {  // Add spacing between elements
        CardView()
            .glassEffect()

        // Sheets use system glass automatically
    }
}
```

### Mistake 3: Adding Custom Shadows/Borders

❌ **Wrong:**
```swift
Button("Action") { }
    .glassEffect()
    .shadow(radius: 10)  // Competes with system edge effect
    .border(Color.white.opacity(0.3))  // Unnecessary
```

✅ **Correct:**
```swift
Button("Action") { }
    .glassEffect()
    // Trust the system - no manual shadows or borders
```

### Mistake 4: Ignoring Reduce Transparency

❌ **Wrong:**
```swift
Button("Action") { }
    .glassEffect()  // Assumes user wants full glass effect
```

✅ **Correct:**
```swift
struct AccessibleGlassButton: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        Button("Action") { }
            .modifier(AdaptiveGlassModifier(reduceTransparency: reduceTransparency))
    }
}

struct AdaptiveGlassModifier: ViewModifier {
    let reduceTransparency: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(reduceTransparency ? .identity : .regular)
        } else {
            content.background(reduceTransparency ? Color.systemBackground : .ultraThinMaterial)
        }
    }
}
```

## Migration from Legacy Designs

### From iOS 13-15 Custom Navigation

Many apps have custom navigation workarounds that looked bad with default iOS. With Liquid Glass, default controls look great:

**Before (iOS 13-15):**
```swift
NavigationView {
    ContentView()
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            CustomNavigationBar()  // Remove this
        }
}
```

**After (iOS 26):**
```swift
NavigationStack {
    ContentView()
        .navigationTitle("Title")
        .toolbar {
            ToolbarItem { /* actions */ }
        }
    // System navigation automatically uses Liquid Glass
}
```

### From UIKit Hybrid Apps

For apps mixing UIKit and SwiftUI:

```swift
// In UIKit
if #available(iOS 26.0, *) {
    navigationBar.prefersLargeTitles = true
    // System applies Liquid Glass automatically
} else {
    // Legacy styling
}
```

## Performance Considerations

1. **Limit glass elements** - Each glass effect has rendering cost
2. **Avoid glass on scrollable content** - Performance impact during scroll
3. **Test on older devices** - iPhone 11 is the minimum for iOS 26
4. **Profile with Instruments** - Check GPU usage with multiple glass elements

## Testing Checklist

- [ ] Verify `#available(iOS 26.0, *)` guards in place
- [ ] Test with Reduce Transparency enabled
- [ ] Test with Reduce Motion enabled
- [ ] Check glass only on navigation layer
- [ ] Verify no stacked glass layers
- [ ] Test corner concentricity in sheets
- [ ] Test tab bar shrink behavior
- [ ] Profile performance on target devices
- [ ] Test dark mode appearance
- [ ] Verify text legibility over glass

## Official Resources

- [Apple Developer Documentation: Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC25 Session 219: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 323: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [GitHub: LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference)
