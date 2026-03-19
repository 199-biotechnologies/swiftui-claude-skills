# SwiftUI Animation Expert Guide

Comprehensive reference for reviewing and implementing animations in SwiftUI for iOS 17/18/26+, including liquid glass morphing, micro-interactions, haptic feedback, and UX best practices.

## Animation Philosophy

### Apple Human Interface Guidelines - Motion Principles

**Use Motion Purposefully:**
- Motion should communicate - showing how things change, what happens on actions, what users can do next
- Don't add motion for the sake of adding motion - gratuitous animation distracts and disconnects
- Avoid motion on frequent interactions - system already provides subtle animations for standard elements

**Physical Realism:**
- Strive for realism and credibility
- Motion that defies physical laws disorients users
- If a view slides down from top, users expect to dismiss by sliding up, not sideways

**Make Motion Optional:**
- Always respect `accessibilityReduceMotion`
- Animation should never be the only way to communicate information

**Ideal Duration:**
- 100ms - 500ms for most UI animations
- Fast enough to feel responsive, slow enough to communicate change

## Animation Types Reference

### 1. Implicit Animations

The simplest form - attach `.animation()` modifier:

```swift
struct ImplicitExample: View {
    @State private var scale = 1.0

    var body: some View {
        Circle()
            .scaleEffect(scale)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)
            .onTapGesture {
                scale = scale == 1.0 ? 1.5 : 1.0
            }
    }
}
```

**Best Practice:** Always use `.animation(_:value:)` with explicit value binding for stable behavior.

### 2. Explicit Animations

Wrap state changes in `withAnimation`:

```swift
struct ExplicitExample: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: isExpanded ? 300 : 100,
                       height: isExpanded ? 200 : 100)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }
}
```

### 3. Spring Animations

Springs create natural, physics-based motion.

**iOS 17+ Simple API:**
```swift
// Duration + bounce
.animation(.spring(duration: 0.5, bounce: 0.3), value: state)

// Bouncy preset
withAnimation(.bouncy) { ... }

// Smooth preset (no overshoot)
withAnimation(.smooth) { ... }

// Snappy preset
withAnimation(.snappy) { ... }
```

**Spring Parameters Explained:**

| Parameter | Effect |
|-----------|--------|
| `response` | Duration before reaching target (0.5 = default) |
| `dampingFraction` | Bounce amount (0 = infinite, 1 = no bounce, 0.8 = standard) |
| `duration` | Total animation duration (iOS 17+) |
| `bounce` | Simplified bounce control (iOS 17+) |

**Spring Presets:**
- `.bouncy` - High bounce, playful (dampingFraction ~0.6)
- `.smooth` - No overshoot, professional (dampingFraction ~1.0)
- `.snappy` - Quick response, minimal bounce
- `.interactiveSpring` - Optimized for gesture-driven animations

```swift
// Recommended springs for different contexts
let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
let modalPresentation = Animation.spring(response: 0.5, dampingFraction: 0.8)
let cardExpansion = Animation.spring(response: 0.6, dampingFraction: 0.85)
let subtleHover = Animation.spring(response: 0.2, dampingFraction: 0.9)
```

### 4. Timing Curve Animations

For non-spring animations:

```swift
.animation(.easeInOut(duration: 0.3), value: state)
.animation(.easeIn(duration: 0.2), value: state)
.animation(.easeOut(duration: 0.4), value: state)
.animation(.linear(duration: 0.1), value: state)
```

**Custom Bezier Curves:**
```swift
Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.3)  // Custom ease
```

### 5. PhaseAnimator (iOS 17+)

Multi-step animations cycling through phases:

```swift
struct PhaseAnimatorExample: View {
    var body: some View {
        PhaseAnimator([false, true]) { phase in
            Image(systemName: "heart.fill")
                .scaleEffect(phase ? 1.2 : 1.0)
                .foregroundStyle(phase ? .red : .pink)
        } animation: { phase in
            phase ? .bouncy : .smooth
        }
    }
}
```

**Triggered PhaseAnimator:**
```swift
struct TriggeredPhaseExample: View {
    @State private var trigger = 0

    var body: some View {
        PhaseAnimator([0, -10, 10, -5, 5, 0], trigger: trigger) { offset in
            Text("Shake me!")
                .offset(x: CGFloat(offset))
        } animation: { _ in
            .spring(response: 0.1, dampingFraction: 0.3)
        }
        .onTapGesture {
            trigger += 1
        }
    }
}
```

**PhaseAnimator with Enums (Recommended):**
```swift
enum BouncePhase: CaseIterable {
    case initial, up, down, settle

    var scale: CGFloat {
        switch self {
        case .initial: return 1.0
        case .up: return 1.3
        case .down: return 0.9
        case .settle: return 1.0
        }
    }

    var rotation: Angle {
        switch self {
        case .initial: return .zero
        case .up: return .degrees(-5)
        case .down: return .degrees(5)
        case .settle: return .zero
        }
    }
}

struct EnumPhaseExample: View {
    @State private var trigger = 0

    var body: some View {
        PhaseAnimator(BouncePhase.allCases, trigger: trigger) { phase in
            Image(systemName: "star.fill")
                .scaleEffect(phase.scale)
                .rotationEffect(phase.rotation)
        }
        .onTapGesture { trigger += 1 }
    }
}
```

### 6. KeyframeAnimator (iOS 17+)

Fine-grained control with keyframe tracks:

```swift
struct KeyframeExample: View {
    @State private var trigger = false

    var body: some View {
        Text("Hello!")
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: trigger
            ) { content, value in
                content
                    .scaleEffect(value.scale)
                    .offset(y: value.yOffset)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.2, duration: 0.2)
                    SpringKeyframe(0.9, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.2)
                }
                KeyframeTrack(\.yOffset) {
                    LinearKeyframe(-20, duration: 0.15)
                    SpringKeyframe(0, duration: 0.3, spring: .bouncy)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0.7, duration: 0.1)
                    LinearKeyframe(1.0, duration: 0.2)
                }
            }
            .onTapGesture { trigger.toggle() }
    }
}

struct AnimationValues {
    var scale: CGFloat = 1.0
    var yOffset: CGFloat = 0
    var opacity: Double = 1.0
}
```

**Keyframe Types:**
| Type | Behavior |
|------|----------|
| `CubicKeyframe` | Smooth cubic bezier transition |
| `SpringKeyframe` | Physics-based spring |
| `LinearKeyframe` | Linear interpolation |
| `MoveKeyframe` | Instant jump (no animation) |

### 7. matchedGeometryEffect

Hero animations between views:

```swift
struct HeroAnimationExample: View {
    @Namespace private var animation
    @State private var isExpanded = false

    var body: some View {
        VStack {
            if isExpanded {
                ExpandedView()
                    .matchedGeometryEffect(id: "card", in: animation)
                    .matchedGeometryEffect(id: "title", in: animation, properties: .position)
            } else {
                CompactView()
                    .matchedGeometryEffect(id: "card", in: animation)
                    .matchedGeometryEffect(id: "title", in: animation, properties: .position)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }
}
```

**Important:** matchedGeometryEffect requires both views to exist in the same view hierarchy context. The `.id()` creates different identities, not matched geometry.

### 8. Transitions

Animate view insertion/removal:

```swift
struct TransitionExample: View {
    @State private var showContent = false

    var body: some View {
        VStack {
            if showContent {
                ContentView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showContent.toggle()
            }
        }
    }
}
```

**Built-in Transitions:**
- `.opacity` - Fade in/out
- `.slide` - Slide from leading, exit to trailing
- `.move(edge:)` - Move from specific edge
- `.scale` - Scale from center
- `.push(from:)` - Push transition (iOS 16+)
- `.blurReplace` - Blur transition (iOS 17+)

**Custom Transitions:**
```swift
extension AnyTransition {
    static var customSlideUp: AnyTransition {
        .modifier(
            active: SlideModifier(offset: 50, opacity: 0),
            identity: SlideModifier(offset: 0, opacity: 1)
        )
    }
}

struct SlideModifier: ViewModifier {
    let offset: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
    }
}
```

## iOS 26 Animation APIs (WWDC 2025)

### @Animatable Macro (iOS 26+)

The `@Animatable` macro simplifies animating custom Shape types and view modifiers by automatically synthesizing `Animatable` protocol conformance:

```swift
import SwiftUI

@Animatable
struct AnimatedShape: Shape {
    var progress: CGFloat  // Automatically animatable
    var cornerRadius: CGFloat  // Automatically animatable

    func path(in rect: CGRect) -> Path {
        // Shape implementation using progress and cornerRadius
        Path(roundedRect: rect, cornerRadius: cornerRadius * progress)
    }
}

// Usage
struct AnimatedShapeView: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        AnimatedShape(progress: progress, cornerRadius: 20)
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    progress = progress == 0 ? 1 : 0
                }
            }
    }
}
```

**Before iOS 26 (manual implementation):**
```swift
// Required verbose manual implementation
struct OldAnimatedShape: Shape, Animatable {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    // ... rest of implementation
}
```

### @AnimatableIgnored Macro (iOS 26+)

Exclude specific properties from animation interpolation:

```swift
@Animatable
struct SelectiveAnimationShape: Shape {
    var animatedValue: CGFloat       // Will animate
    @AnimatableIgnored var isActive: Bool  // Won't animate, instant change

    func path(in rect: CGRect) -> Path {
        // Implementation
    }
}
```

### SF Symbols "Draw On" Animations (iOS 26+)

New symbol effect for stroke-based reveal animations:

```swift
Image(systemName: "checkmark.circle")
    .symbolEffect(.drawOn)  // Animated stroke drawing

// With configuration
Image(systemName: "star")
    .symbolEffect(.drawOn, options: .speed(0.5))

// Triggered animation
Image(systemName: "heart")
    .symbolEffect(.drawOn, isActive: isComplete)
```

**Available SF Symbol Effects (iOS 17+, enhanced iOS 26):**
| Effect | Description |
|--------|-------------|
| `.pulse` | Gentle pulsing |
| `.bounce` | Bouncy emphasis |
| `.scale` | Scale up/down |
| `.appear` | Fade in appearance |
| `.disappear` | Fade out |
| `.replace` | Symbol replacement transition |
| `.variableColor` | Animated color layers |
| `.drawOn` | **NEW iOS 26**: Stroke drawing animation |

### TabView Minimize on Scroll (iOS 26+)

Tab bars automatically shrink during scroll:

```swift
TabView {
    ScrollView {
        // Content - tabs auto-minimize on scroll
    }
    .tabItem { Label("Home", systemImage: "house") }
}
// No additional configuration needed - behavior is automatic in iOS 26
```

### backgroundExtensionEffect (iOS 26+)

Extend and blur content beyond view boundaries:

```swift
Image("hero")
    .backgroundExtensionEffect()  // Extends blur beyond edges
```

## Liquid Glass Morphing Animations (iOS 26+)

### GlassEffectContainer Morphing

```swift
struct MorphingGlassExample: View {
    @Namespace private var glassNamespace
    @State private var isExpanded = false

    var body: some View {
        GlassEffectContainer {
            if isExpanded {
                ExpandedToolbar()
                    .glassEffect()
                    .glassEffectID("toolbar", in: glassNamespace)
            } else {
                CompactFAB()
                    .glassEffect()
                    .glassEffectID("toolbar", in: glassNamespace)
            }
        }
        .onTapGesture {
            withAnimation(.bouncy) {
                isExpanded.toggle()
            }
        }
    }
}
```

### Interactive Glass Effects

```swift
Button("Press Me") { }
    .glassEffect(.regular.interactive())  // Adds press scale, shimmer, illumination
```

### Glass Transition Best Practices

1. **Use `.bouncy` animation** for glass morphing
2. **Coordinate with GlassEffectContainer** - elements must share a container to morph
3. **Use `glassEffectID`** for morph coordination
4. **Animate state changes** with `withAnimation(.bouncy)`

## Counter and Numeric Animations

### ContentTransition for Numbers (iOS 16+)

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        Text("\(count)")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .contentTransition(.numericText(countsDown: false))
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    count += 1
                }
            }
    }
}
```

### Rolling Digit Counter

```swift
struct RollingCounter: View {
    let value: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(format: "%03d", value)), id: \.self) { digit in
                Text(String(digit))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .frame(width: 36)
                    .id(digit)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
    }
}
```

## Text Animations

### Text with ID Transition

```swift
struct AnimatedTextView: View {
    @State private var currentText = "Hello"

    var body: some View {
        Text(currentText)
            .font(.largeTitle)
            .id(currentText)  // Forces view recreation
            .transition(.blurReplace)  // iOS 17+
    }
}
```

### Typewriter Effect

```swift
struct TypewriterText: View {
    let text: String
    @State private var displayedText = ""

    var body: some View {
        Text(displayedText)
            .onAppear {
                typeText()
            }
    }

    private func typeText() {
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText.append(character)
            }
        }
    }
}
```

### Text Shimmer Effect

```swift
struct ShimmerText: View {
    let text: String
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundStyle(
                LinearGradient(
                    colors: [.gray, .white, .gray],
                    startPoint: UnitPoint(x: shimmerOffset - 0.3, y: 0.5),
                    endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 0.5)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 2.0
                }
            }
    }
}
```

## Onboarding Animations

### Page Transition with Parallax

```swift
struct OnboardingView: View {
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<3) { index in
                OnboardingPage(index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
    }
}

struct OnboardingPage: View {
    let index: Int

    var body: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .global).minX
            let parallax = offset / geo.size.width

            VStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .offset(x: parallax * 50)  // Parallax effect

                Text("Page \(index + 1)")
                    .font(.title)
                    .offset(x: parallax * 30)  // Less parallax for text
            }
        }
    }
}
```

### Staggered Entry Animation

```swift
struct StaggeredOnboarding: View {
    @State private var animateContent = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateContent)

            Text("Welcome")
                .font(.largeTitle.bold())
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateContent)

            Text("Get started with our app")
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateContent)

            Button("Continue") { }
                .buttonStyle(.borderedProminent)
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: animateContent)
        }
        .onAppear {
            animateContent = true
        }
    }
}
```

## Tab Bar Animations

### Custom Animated Tab Indicator

```swift
struct AnimatedTabBar: View {
    @State private var selectedTab = 0
    @Namespace private var tabAnimation

    let tabs = ["house", "magnifyingglass", "heart", "person"]

    var body: some View {
        HStack {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index])
                            .font(.system(size: 24))
                            .foregroundStyle(selectedTab == index ? .primary : .secondary)

                        if selectedTab == index {
                            Circle()
                                .fill(.primary)
                                .frame(width: 6, height: 6)
                                .matchedGeometryEffect(id: "indicator", in: tabAnimation)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
    }
}
```

## Micro-Interactions and Haptic Feedback

### Button Press Animation

```swift
struct AnimatedButton: View {
    @State private var isPressed = false

    var body: some View {
        Text("Press Me")
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
```

### Sensory Feedback (iOS 17+)

```swift
struct HapticButton: View {
    @State private var count = 0

    var body: some View {
        Button {
            count += 1
        } label: {
            Text("Count: \(count)")
                .contentTransition(.numericText())
        }
        .sensoryFeedback(.increase, trigger: count)
    }
}
```

**Haptic Types:**
| Type | Use Case |
|------|----------|
| `.success` | Successful completion |
| `.warning` | Caution needed |
| `.error` | Failed action |
| `.selection` | Selection change |
| `.increase` | Value increased |
| `.decrease` | Value decreased |
| `.start` | Activity started |
| `.stop` | Activity stopped |
| `.impact` | Physical collision |

### Combined Animation + Haptic

```swift
struct InteractiveCard: View {
    @State private var isLiked = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isLiked.toggle()
            }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 32))
                .foregroundStyle(isLiked ? .red : .gray)
                .scaleEffect(isLiked ? 1.2 : 1.0)
        }
        .sensoryFeedback(isLiked ? .success : .selection, trigger: isLiked)
    }
}
```

## Loading and Skeleton Animations

### Shimmer Skeleton

```swift
struct ShimmerSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * 0.5)
                        .offset(x: shimmer ? geo.size.width : -geo.size.width * 0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
    }
}
```

### Pulsing Loading Indicator

```swift
struct PulsingLoader: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 20, height: 20)
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
```

## Performance Best Practices

### Common Mistakes to Avoid

| Mistake | Impact | Solution |
|---------|--------|----------|
| Heavy work during keyframes | Frame drops | Use `drawingGroup()` or simplify view |
| Animating complex views | Stuttering | Pre-render with `drawingGroup()` |
| Multiple simultaneous `withAnimation` | Conflicts | Use single animation block |
| Animating during scroll | Jank | Defer animations until scroll ends |
| `.animation()` without value | Unpredictable | Always use `.animation(_:value:)` |

### Performance Optimization

```swift
// Offscreen rendering for complex animations
ComplexAnimatedView()
    .drawingGroup()  // Composites to Metal texture

// Reduce animation scope
struct OptimizedView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            ExpensiveStaticView()  // Not animated

            AnimatedElement()
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring, value: isAnimating)
        }
    }
}
```

### Accessibility Considerations

```swift
struct AccessibleAnimation: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        Content()
            .scaleEffect(isExpanded ? 1.2 : 1.0)
            .animation(
                reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7),
                value: isExpanded
            )
    }
}
```

## Animation Review Checklist

### Motion Quality
- [ ] Springs used for interactive elements (not linear/ease)
- [ ] Duration between 100-500ms for UI animations
- [ ] No jarring or abrupt motion
- [ ] Physics feel realistic and grounded

### Purpose
- [ ] Animation communicates state change
- [ ] Not gratuitous or excessive
- [ ] Frequent interactions use subtle animations
- [ ] Critical information not conveyed by motion alone

### Accessibility
- [ ] Respects `accessibilityReduceMotion`
- [ ] Respects `accessibilityReduceTransparency`
- [ ] Alternative feedback (haptic/visual) when motion disabled

### Performance
- [ ] No frame drops during animation
- [ ] `drawingGroup()` used for complex animated views
- [ ] Animations don't conflict with scrolling
- [ ] `.animation(_:value:)` used (not valueless)

### iOS 26 Liquid Glass
- [ ] Glass morphing uses `GlassEffectContainer`
- [ ] `glassEffectID` coordinated properly
- [ ] `.bouncy` animation for glass transitions
- [ ] No glass on content layer

## GitHub Resources and Libraries

### Official Apple Resources
- [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Animating views and transitions](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)
- [WWDC23: Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)
- [WWDC18: Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/)

### Animation Libraries
- [Pow](https://github.com/EmergeTools/Pow) - Delightful SwiftUI effects (Spray, Shake, Shine, Jump, Rise, Spin, etc.)
- [AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - Preset tab bar animations (parabolic, teleport, straight)
- [open-swiftui-animations](https://github.com/amosgyamfi/open-swiftui-animations) - Loading, looping, fade, spin examples
- [Hero](https://github.com/HeroTransitions/Hero) - Elegant transition library
- [FlowStack](https://github.com/velos/FlowStack) - Hero animations with NavigationStack API

### Hero Transitions
- [swiftui-hero-animations](https://github.com/swiftui-lab/swiftui-hero-animations) - matchedGeometryEffect examples
- [swiftui-hero-animations-no-transitions](https://github.com/swiftui-lab/swiftui-hero-animations-no-transitions) - Morphing without transitions

### Skeleton Loading
- [SkeletonUI](https://github.com/CSolanaM/SkeletonUI) - Elegant skeleton loading
- [JTSkeleton](https://github.com/Enryun/JTSkeleton) - Customizable skeleton with shimmer

### Liquid Glass (iOS 26)
- [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference) - Ultimate Swift/SwiftUI reference
- [LiquidGlassSwiftUI](https://github.com/mertozseven/LiquidGlassSwiftUI) - Sample app with morphing

### Tutorials and Guides
- [SwiftUI Lab - Advanced Animations](https://swiftui-lab.com/swiftui-animations-part7/) - PhaseAnimator deep dive
- [AppCoda - KeyframeAnimator](https://www.appcoda.com/keyframeanimator/) - iOS 17 keyframes
- [Hacking with Swift - Spring Animations](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-spring-animation)
- [Design+Code - Phase Animator](https://designcode.io/swiftui-handbook-phase-animator/)
- [Jacob's Tech Tavern - Keyframe Animations](https://blog.jacobstechtavern.com/p/swiftui-keyframe-animations)
- [objc.io - Animation Timing Curves](https://www.objc.io/blog/2019/09/26/swiftui-animation-timing-curves/)
- [Kodeco - SwiftUI Animations Tutorial](https://www.kodeco.com/books/swiftui-animations-by-tutorials/)
