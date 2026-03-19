# Using modern SwiftUI API

- Always use `foregroundStyle()` instead of `foregroundColor()`.
- Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.
- Always use the `Tab` API instead of `tabItem()`.
- Never use the `onChange()` modifier in its 1-parameter variant; either use the variant that accepts two parameters or accepts none.
- Do not use `GeometryReader` if a newer alternative works: `containerRelativeFrame()`, `visualEffect()`, or the `Layout` protocol. Flag `GeometryReader` usage and suggest the modern alternative.
- When designing haptic effects, prefer using `sensoryFeedback()` over older UIKit APIs such as `UIImpactFeedbackGenerator`.
- Use the `@Entry` macro to define custom `EnvironmentValues`, `FocusValues`, `Transaction`, and `ContainerValues` keys. This replaces the legacy pattern of manually creating a type conforming to (for example) `EnvironmentKey` with a `defaultValue`, then extending `EnvironmentValues` with a computed property.
- Strongly prefer `overlay(alignment:content:)` over the deprecated `overlay(_:alignment:)`. For example, use `.overlay { Text("Hello, world!") }` rather than `.overlay(Text("Hello, world!"))`.
- Never use `.navigationBarLeading` and `.navigationBarTrailing` for toolbar item placement; they are deprecated. The correct, modern placements are `.topBarLeading` and `.topBarTrailing`.
- Prefer to rely on automatic grammar agreement when dealing with English, French, German, Portuguese, Spanish, and Italian. For example, use `Text("^[\(people) person](inflect: true)")` to show a number of people.
- You can fill and stroke a shape with two chained modifiers; you do *not* need an overlay for the stroke. The overlay was required previously, but this is fixed in iOS 17 and later.
- When referencing images from an asset catalog, prefer the generated symbol asset API when the project is configured to use them: `Image(.avatar)` rather than `Image("avatar")`.
- When targeting iOS 26 and later, SwiftUI has a native `WebView` view type that replaces almost all uses of hand-wrapped `WKWebView` inside `UIViewRepresentable`. To use it, make sure to include `import WebKit`.
- `ForEach` over an `enumerated()` sequence should not convert to an array first. Use `ForEach(items.enumerated(), id: \.element.id)` directly.
- When hiding scroll indicators, use `.scrollIndicators(.hidden)` rather than `showsIndicators: false` in the initializer.
- Never use `Text` concatenation with `+`.

For example, the usage of `+` here is bad and deprecated:

```swift
Text("Hello").foregroundStyle(.red)
+
Text("World").foregroundStyle(.blue)
```

Instead, use text interpolation like this:

```swift
let red = Text("Hello").foregroundStyle(.red)
let blue = Text("World").foregroundStyle(.blue)
Text("\(red)\(blue)")
```


## iOS 26 Liquid Glass APIs

When targeting iOS 26+, standard navigation elements (nav bars, toolbars, tab bars, sheets) automatically adopt Liquid Glass. For custom glass UI:

- Use `.glassEffect()` for custom glass surfaces. The three variants are `.regular` (default), `.clear` (high transparency for media backgrounds), and `.identity` (no effect, for conditional toggling). **There is no `.prominent` variant** — use `.buttonStyle(.glassProminent)` for prominent buttons instead.
- Use `.glassEffect(.regular.interactive())` for glass that responds to touch/pointer with scaling, bounce, and shimmer.
- Use `.glassEffect(.regular.tint(.blue))` for tinted glass (call-to-action only, never decorative).
- Wrap multiple glass views in `GlassEffectContainer(spacing:)` — glass cannot sample other glass.
- Use `.glassEffectID(_:in:)` with `@Namespace` for morphing transitions between glass states.
- Use `.glassEffectUnion(id:namespace:)` to merge related controls into a single glass shape (like Apple Maps zoom controls).
- Use `.buttonStyle(.glass)` for secondary actions and `.buttonStyle(.glassProminent)` for primary actions.
- Apply `.glassEffect()` **after** layout and appearance modifiers in the modifier chain.
- Do NOT add custom shadows or borders to glass elements — the system handles edge effects.
- Do NOT use `presentationBackground()` on sheets — iOS 26 applies glass automatically.
- Always gate with `#available(iOS 26, *)` and provide a non-glass fallback using `.background(.ultraThinMaterial)`.

## iOS 26 New Layout & Navigation APIs

- `tabViewBottomAccessory { }` — persistent control above the tab bar (like Apple Music's Now Playing bar). Gets glass capsule styling automatically.
- `ToolbarSpacer(.fixed)` / `ToolbarSpacer(.flexible)` — control spacing between toolbar items.
- `.searchToolbarBehavior(.minimize)` — renders search as expandable button instead of full field.
- `.sharedBackgroundVisibility(.hidden)` — controls glass background per toolbar item.
- `toolbar(id:)` — customizable toolbars where users can add/remove/reorder items.
- `.backgroundExtensionEffect()` — extends and blurs content behind sidebars/inspectors.
- `.scrollExtensionMode(.underSidebar)` — extends horizontal scroll content under sidebar.
- `.scrollEdgeEffectStyle(.soft, for: .top)` — controls how content fades at scroll edges (`.soft`, `.hard`, `.automatic`).
- `.windowResizeAnchor(.top)` — controls which edge anchors when window resizes (macOS Settings tabs).
- Sheet morphing: use `.matchedTransitionSource(id:in:)` on the presenting element and `.navigationTransition(.zoom(sourceID:in:))` on the sheet content.
- `TextEditor(text: $attributedString)` — native rich text editing with `AttributedString` binding.
- `.findNavigator(isPresented:)` — macOS find bar for TextEditor.
- `.labelIconToTitleSpacing(_:)` and `.labelReservedIconWidth(_:)` — label layout fine-tuning.
- `DefaultToolbarItem(kind: .search, placement:)` — repositions system search in toolbar.

## iOS 26 NavigationLink Gesture Workaround

NavigationLink in iOS 26 swallows child gestures due to a gesture recognizer refactor. Workarounds:
- Apply `.buttonStyle(.plain)` to strip UIButton traits.
- Use `.simultaneousGesture()` for secondary actions.
- Use `.highPriorityGesture()` for primary actions.
- Add `.contentShape(Rectangle())` for proper hit testing.
This is device-only (simulator uses legacy logic).

## Using ObservableObject

If using `ObservableObject` is absolutely required – for example if you are trying to create a debouncer using a Combine publisher – you should always make sure `import Combine` is added. This was previously provided through SwiftUI, but that is no longer the case.
