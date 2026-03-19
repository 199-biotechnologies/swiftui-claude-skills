# SwiftUI Accessibility Checklist

## Quick Reference: Essential Modifiers

| Modifier | Purpose | Example |
|----------|---------|---------|
| `.accessibilityLabel()` | Descriptive text for VoiceOver | `.accessibilityLabel("Delete item")` |
| `.accessibilityHint()` | What happens after interaction | `.accessibilityHint("Double tap to delete")` |
| `.accessibilityValue()` | Current value of control | `.accessibilityValue("50 percent")` |
| `.accessibilityElement(children:)` | Group/ignore children | `.accessibilityElement(children: .combine)` |
| `.accessibilityHidden()` | Hide from assistive tech | `.accessibilityHidden(true)` |
| `.accessibilityIdentifier()` | For UI testing | `.accessibilityIdentifier("deleteButton")` |
| `.accessibilityAction()` | Custom VoiceOver actions | `.accessibilityAction(named: "Delete") { }` |
| `.accessibilityAddTraits()` | Add semantic traits | `.accessibilityAddTraits(.isButton)` |
| `.accessibilityRemoveTraits()` | Remove traits | `.accessibilityRemoveTraits(.isImage)` |

## VoiceOver Implementation

### Labels for Interactive Elements

Every interactive element needs a meaningful label:

```swift
// ❌ Bad: Image-only button with no label
Button {
    delete()
} label: {
    Image(systemName: "trash")
}
// VoiceOver: "Button" (unhelpful)

// ✅ Good: Button with accessibility label
Button {
    delete()
} label: {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete")
// VoiceOver: "Delete, button"
```

### Labels vs Hints

- **Label**: What the element IS ("Play button", "Volume slider")
- **Hint**: What HAPPENS on interaction ("Double tap to play", "Swipe up or down to adjust volume")

```swift
Button {
    togglePlay()
} label: {
    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
}
.accessibilityLabel(isPlaying ? "Pause" : "Play")
.accessibilityHint("Double tap to \(isPlaying ? "pause" : "play") the track")
```

### Dynamic Values

For controls with changing values:

```swift
Slider(value: $volume, in: 0...100)
    .accessibilityLabel("Volume")
    .accessibilityValue("\(Int(volume)) percent")
```

### Grouping Elements

Combine related elements into single accessibility focus:

```swift
// ❌ Bad: VoiceOver reads each element separately
HStack {
    Image(systemName: "star.fill")
    Text("4.5")
    Text("(238 reviews)")
}
// VoiceOver: "star fill, image" → "4.5" → "(238 reviews)"

// ✅ Good: Combined into meaningful unit
HStack {
    Image(systemName: "star.fill")
    Text("4.5")
    Text("(238 reviews)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Rating: 4.5 stars, 238 reviews")
// VoiceOver: "Rating: 4.5 stars, 238 reviews"
```

### Ignoring Decorative Elements

Hide purely visual elements:

```swift
HStack {
    Image(systemName: "circle.fill")
        .foregroundStyle(.green)
        .accessibilityHidden(true)  // Decorative indicator

    Text("Online")
}
// VoiceOver only reads "Online"
```

### Custom Actions

Add additional actions for VoiceOver users:

```swift
struct ItemRow: View {
    let item: Item
    @State private var isFavorite = false

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            if isFavorite {
                Image(systemName: "heart.fill")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityAction(named: isFavorite ? "Remove from favorites" : "Add to favorites") {
            isFavorite.toggle()
        }
        .accessibilityAction(named: "Delete") {
            delete()
        }
    }
}
```

### Focus Order

Control navigation order with sort priority:

```swift
VStack {
    // Should be read second
    Text("Subtitle")
        .accessibilitySortPriority(1)

    // Should be read first
    Text("Title")
        .accessibilitySortPriority(2)
}
```

### Tap Gestures Need Traits

When using `onTapGesture`, add button trait:

```swift
// ❌ Bad: Tap gesture with no accessibility
Text("Learn More")
    .onTapGesture {
        showMore()
    }
// VoiceOver: "Learn More" (doesn't indicate it's tappable)

// ✅ Good: With accessibility traits
Text("Learn More")
    .onTapGesture {
        showMore()
    }
    .accessibilityAddTraits(.isButton)
    .accessibilityHint("Double tap to learn more")
// VoiceOver: "Learn More, button. Double tap to learn more"
```

## Dynamic Type

### System Fonts Scale Automatically

```swift
// ✅ Good: Uses system font that scales
Text("Title")
    .font(.headline)

Text("Body text")
    .font(.body)

// ❌ Bad: Fixed size doesn't scale
Text("Title")
    .font(.system(size: 17))
```

### Custom Fonts with Scaling

```swift
// Make custom fonts scale with Dynamic Type
Text("Custom Font")
    .font(.custom("Avenir", size: 17, relativeTo: .body))
```

### Responding to Size Changes

```swift
struct AdaptiveLayout: View {
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        if sizeCategory >= .accessibilityLarge {
            VStack {
                // Vertical layout for large text
                Image(systemName: "star")
                Text("Rating")
            }
        } else {
            HStack {
                // Horizontal layout for standard text
                Image(systemName: "star")
                Text("Rating")
            }
        }
    }
}
```

### Limiting Text Size (Use Sparingly)

```swift
// Only when absolutely necessary (e.g., space-constrained UI)
Text("Label")
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
```

## Color and Contrast

### Use Semantic Colors

```swift
// ✅ Good: Adapts to light/dark mode and accessibility settings
Text("Title")
    .foregroundStyle(.primary)

Text("Description")
    .foregroundStyle(.secondary)

// ❌ Bad: Hardcoded colors may have poor contrast
Text("Title")
    .foregroundStyle(Color(hex: "#333333"))
```

### Don't Rely on Color Alone

```swift
// ❌ Bad: Status indicated only by color
Circle()
    .fill(isOnline ? .green : .red)

// ✅ Good: Color + icon + label
HStack {
    Circle()
        .fill(isOnline ? .green : .red)
    Image(systemName: isOnline ? "checkmark.circle" : "xmark.circle")
    Text(isOnline ? "Online" : "Offline")
}
.accessibilityElement(children: .combine)
.accessibilityLabel(isOnline ? "Status: Online" : "Status: Offline")
```

### Check Differentiate Without Color

```swift
struct AdaptiveStatusView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    var body: some View {
        HStack {
            Circle()
                .fill(status.color)

            if differentiateWithoutColor {
                Image(systemName: status.icon)
            }

            Text(status.label)
        }
    }
}
```

## Reduce Motion

```swift
struct AnimatedView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Circle()
            .animation(reduceMotion ? nil : .spring(), value: isExpanded)
    }
}
```

## Reduce Transparency (Liquid Glass)

```swift
struct AdaptiveGlassView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(reduceTransparency ? .identity : .regular)
        } else {
            content
                .background(reduceTransparency ? Color(.systemBackground) : .ultraThinMaterial)
        }
    }
}
```

## Complete Accessibility Audit Checklist

### VoiceOver

- [ ] All interactive elements have meaningful labels
- [ ] Image-only buttons have accessibility labels
- [ ] Related elements are grouped appropriately
- [ ] Decorative images are hidden from VoiceOver
- [ ] Custom gestures have VoiceOver alternatives
- [ ] Focus order is logical and intuitive
- [ ] Dynamic content changes are announced
- [ ] Form fields have associated labels

### Dynamic Type

- [ ] All text uses system or relative-scaled fonts
- [ ] Layout adapts to larger text sizes
- [ ] No truncated or overlapping text at largest sizes
- [ ] Critical text isn't limited below accessibility sizes
- [ ] Tested with all Dynamic Type sizes

### Color and Contrast

- [ ] Text has sufficient contrast (4.5:1 for body, 3:1 for large)
- [ ] Information isn't conveyed by color alone
- [ ] Semantic colors used (`.primary`, `.secondary`)
- [ ] Tested with color filters enabled
- [ ] Works in both light and dark mode

### Motion

- [ ] Reduce Motion preference is respected
- [ ] Essential animations work without motion
- [ ] Autoplay animations can be paused
- [ ] No vestibular-triggering animations

### Transparency (iOS 26)

- [ ] Reduce Transparency preference checked
- [ ] Liquid Glass has solid fallback
- [ ] Text remains readable over glass
- [ ] Tested with Reduce Transparency enabled

### Touch and Interaction

- [ ] Touch targets are at least 44x44 points
- [ ] Adequate spacing between targets
- [ ] No time-dependent interactions
- [ ] All gestures have alternatives

### General

- [ ] Tested with actual VoiceOver on device
- [ ] Tested with Voice Control
- [ ] Tested with Switch Control
- [ ] Accessibility Inspector shows no warnings

## Testing Accessibility

### In Xcode

```swift
// Preview with different accessibility settings
#Preview {
    ContentView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview {
    ContentView()
        .environment(\.accessibilityReduceTransparency, true)
}

#Preview {
    ContentView()
        .environment(\.colorScheme, .dark)
}
```

### Using Accessibility Inspector

1. Open Xcode → Open Developer Tool → Accessibility Inspector
2. Select your simulator/device
3. Audit tab shows issues
4. Inspection tab reads out VoiceOver announcements

### On-Device Testing

**VoiceOver:**
- Settings → Accessibility → VoiceOver
- Use two-finger swipe to navigate
- Double-tap to activate

**Dynamic Type:**
- Settings → Accessibility → Display & Text Size → Larger Text

**Reduce Motion:**
- Settings → Accessibility → Motion → Reduce Motion

**Reduce Transparency:**
- Settings → Accessibility → Display & Text Size → Reduce Transparency

## External Resources

- [Accessibility in SwiftUI](https://wesleydegroot.nl/blog/accessibility-in-swiftui)
- [VoiceOver SwiftUI Guide](https://tanaschita.com/ios-accessibility-voiceover-swiftui-guide/)
- [Dynamic Type in SwiftUI](https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/1-responding-to-dynamic-type-in-swiftui-for-accessibility)
- [Orange Accessibility Guidelines](https://a11y-guidelines.orange.com/en/mobile/ios/development/)
- [Apple Accessibility Documentation](https://developer.apple.com/documentation/accessibility)
