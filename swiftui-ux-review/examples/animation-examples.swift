// MARK: - SwiftUI Animation Examples
// Comprehensive examples for iOS 17/18/26+ animation patterns

import SwiftUI

// MARK: - 1. Spring Animation Standards

/// Button with proper spring animation and haptic feedback
struct AnimatedButton: View {
    @State private var isPressed = false
    @State private var tapCount = 0

    var body: some View {
        Button {
            tapCount += 1
        } label: {
            Text("Tap Me (\(tapCount))")
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 2. PhaseAnimator Examples

/// Attention-seeking animation with PhaseAnimator
struct AttentionButton: View {
    enum Phase: CaseIterable {
        case idle, pulse, settle

        var scale: CGFloat {
            switch self {
            case .idle: return 1.0
            case .pulse: return 1.15
            case .settle: return 1.0
            }
        }

        var opacity: Double {
            switch self {
            case .idle: return 1.0
            case .pulse: return 0.8
            case .settle: return 1.0
            }
        }
    }

    var body: some View {
        PhaseAnimator(Phase.allCases) { phase in
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
                .scaleEffect(phase.scale)
                .opacity(phase.opacity)
        } animation: { phase in
            switch phase {
            case .idle: return .spring(response: 0.8, dampingFraction: 0.5)
            case .pulse: return .spring(response: 0.2, dampingFraction: 0.4)
            case .settle: return .spring(response: 0.3, dampingFraction: 0.8)
            }
        }
    }
}

/// Triggered shake animation for error feedback
struct ShakeView: View {
    @State private var trigger = 0

    var body: some View {
        VStack(spacing: 20) {
            PhaseAnimator([0, -10, 10, -8, 8, -4, 4, 0], trigger: trigger) { offset in
                TextField("Enter value", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .offset(x: CGFloat(offset))
            } animation: { _ in
                .spring(response: 0.08, dampingFraction: 0.3)
            }

            Button("Trigger Error") {
                trigger += 1
            }
            .sensoryFeedback(.error, trigger: trigger)
        }
        .padding()
    }
}

// MARK: - 3. KeyframeAnimator Examples

/// Complex multi-property animation with keyframes
struct BounceInView: View {
    @State private var trigger = false

    struct AnimationValues {
        var scale: CGFloat = 0.5
        var yOffset: CGFloat = -50
        var opacity: Double = 0
        var rotation: Angle = .degrees(-15)
    }

    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle.bold())
                .keyframeAnimator(
                    initialValue: AnimationValues(),
                    trigger: trigger
                ) { content, value in
                    content
                        .scaleEffect(value.scale)
                        .offset(y: value.yOffset)
                        .opacity(value.opacity)
                        .rotationEffect(value.rotation)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(1.2, duration: 0.3)
                        SpringKeyframe(0.9, duration: 0.15)
                        SpringKeyframe(1.0, duration: 0.2, spring: .bouncy)
                    }

                    KeyframeTrack(\.yOffset) {
                        SpringKeyframe(10, duration: 0.3)
                        SpringKeyframe(0, duration: 0.35, spring: .bouncy)
                    }

                    KeyframeTrack(\.opacity) {
                        LinearKeyframe(1.0, duration: 0.2)
                    }

                    KeyframeTrack(\.rotation) {
                        CubicKeyframe(.degrees(5), duration: 0.2)
                        SpringKeyframe(.zero, duration: 0.3)
                    }
                }

            Button("Animate") {
                trigger.toggle()
            }
            .padding(.top, 40)
        }
    }
}

// MARK: - 4. Counter Animation

/// Animated counter with numeric content transition
struct AnimatedCounter: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("\(count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .contentTransition(.numericText(countsDown: count < 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)

            HStack(spacing: 20) {
                Button("-") { count -= 1 }
                    .sensoryFeedback(.decrease, trigger: count)

                Button("+") { count += 1 }
                    .sensoryFeedback(.increase, trigger: count)
            }
            .font(.title)
        }
    }
}

// MARK: - 5. Hero Transition with matchedGeometryEffect

/// Card expansion with hero animation
struct HeroCardView: View {
    @Namespace private var animation
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            if isExpanded {
                // Expanded state
                VStack(spacing: 0) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .matchedGeometryEffect(id: "image", in: animation)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Card Title")
                            .font(.title.bold())
                            .matchedGeometryEffect(id: "title", in: animation)

                        Text("This is the expanded description with more details about the content. You can add as much information as needed here.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 0))
                .matchedGeometryEffect(id: "background", in: animation)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }
            } else {
                // Compact state
                VStack(alignment: .leading, spacing: 0) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .matchedGeometryEffect(id: "image", in: animation)

                    Text("Card Title")
                        .font(.headline)
                        .padding()
                        .matchedGeometryEffect(id: "title", in: animation)
                }
                .frame(width: 280)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .matchedGeometryEffect(id: "background", in: animation)
                .shadow(radius: 10)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
            }
        }
    }
}

// MARK: - 6. Tab Indicator Animation

/// Animated tab bar with sliding indicator
struct AnimatedTabIndicator: View {
    @State private var selectedTab = 0
    @Namespace private var tabAnimation

    let tabs = ["house.fill", "magnifyingglass", "heart.fill", "person.fill"]

    var body: some View {
        HStack(spacing: 0) {
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
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)

                        if selectedTab == index {
                            Capsule()
                                .fill(.primary)
                                .frame(width: 20, height: 3)
                                .matchedGeometryEffect(id: "indicator", in: tabAnimation)
                        } else {
                            Capsule()
                                .fill(.clear)
                                .frame(width: 20, height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - 7. Staggered Entry Animation

/// Staggered list item appearance
struct StaggeredListView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    @State private var animatedItems: Set<String> = []

    var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                Text(item)
                    .opacity(animatedItems.contains(item) ? 1 : 0)
                    .offset(x: animatedItems.contains(item) ? 0 : -50)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: animatedItems.contains(item)
                    )
                    .onAppear {
                        animatedItems.insert(item)
                    }
            }
        }
    }
}

// MARK: - 8. Loading Skeleton with Shimmer

/// Shimmer loading skeleton
struct ShimmerSkeletonView: View {
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)

            // Title placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 20)
                .frame(maxWidth: 200)

            // Description placeholders
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 14)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 14)
                .frame(maxWidth: 280)
        }
        .padding()
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
                    .offset(x: shimmerOffset * geo.size.width)
            }
            .mask(
                VStack(alignment: .leading, spacing: 12) {
                    Circle().frame(width: 50, height: 50)
                    RoundedRectangle(cornerRadius: 4).frame(height: 20).frame(maxWidth: 200)
                    RoundedRectangle(cornerRadius: 4).frame(height: 14)
                    RoundedRectangle(cornerRadius: 4).frame(height: 14).frame(maxWidth: 280)
                }
                .padding()
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.5
            }
        }
    }
}

// MARK: - 9. Accessibility-Aware Animation

/// Animation that respects Reduce Motion setting
struct AccessibleAnimatedView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isActive = false

    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .opacity(isActive ? 0.8 : 1.0)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.6),
                    value: isActive
                )

            Button("Toggle") {
                isActive.toggle()
            }

            Text(reduceMotion ? "Reduce Motion: ON" : "Reduce Motion: OFF")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 10. Liquid Glass Morphing (iOS 26+)

/// Glass effect morphing between states
@available(iOS 26.0, *)
struct GlassMorphingView: View {
    @Namespace private var glassNamespace
    @State private var isExpanded = false

    var body: some View {
        GlassEffectContainer {
            VStack {
                if isExpanded {
                    HStack(spacing: 16) {
                        Button("Edit") { }
                        Button("Share") { }
                        Button("Delete") { }
                    }
                    .padding()
                    .glassEffect()
                    .glassEffectID("toolbar", in: glassNamespace)
                } else {
                    Button {
                        withAnimation(.bouncy) {
                            isExpanded = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding()
                    }
                    .glassEffect()
                    .glassEffectID("toolbar", in: glassNamespace)
                }
            }
        }
        .onTapGesture {
            if isExpanded {
                withAnimation(.bouncy) {
                    isExpanded = false
                }
            }
        }
    }
}

// MARK: - 11. @Animatable Macro (iOS 26+)

/// Custom shape with automatic animation support using @Animatable macro
@available(iOS 26.0, *)
@Animatable
struct MorphingShape: Shape {
    var progress: CGFloat  // Automatically animatable
    var cornerRadius: CGFloat  // Automatically animatable

    func path(in rect: CGRect) -> Path {
        let effectiveRadius = cornerRadius * progress
        return Path(roundedRect: rect, cornerRadius: effectiveRadius)
    }
}

@available(iOS 26.0, *)
struct AnimatableMacroDemo: View {
    @State private var isCircle = false

    var body: some View {
        VStack(spacing: 20) {
            MorphingShape(
                progress: isCircle ? 1.0 : 0.3,
                cornerRadius: isCircle ? 75 : 20
            )
            .fill(.blue.gradient)
            .frame(width: 150, height: 150)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isCircle)

            Button("Morph Shape") {
                isCircle.toggle()
            }
        }
    }
}

// MARK: - 12. SF Symbols Draw On Effect (iOS 26+)

/// SF Symbol with animated stroke drawing effect
@available(iOS 26.0, *)
struct SymbolDrawOnDemo: View {
    @State private var trigger = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.drawOn, value: trigger)

            Button("Draw Symbol") {
                trigger += 1
            }
            .sensoryFeedback(.success, trigger: trigger)
        }
    }
}

// MARK: - 13. Background Extension Effect (iOS 26+)

/// Blur effect that extends beyond view bounds
@available(iOS 26.0, *)
struct BackgroundExtensionDemo: View {
    var body: some View {
        ZStack {
            // Background content
            Image(systemName: "photo.artframe")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300)

            // Floating control with blur extension
            VStack {
                Text("Caption")
                    .font(.headline)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .backgroundExtensionEffect()  // Extends blur beyond bounds
        }
    }
}

// MARK: - Preview

#Preview("Animation Examples") {
    ScrollView {
        VStack(spacing: 40) {
            AnimatedButton()
            AttentionButton()
            AnimatedCounter()
            AnimatedTabIndicator()
            ShimmerSkeletonView()
                .frame(maxWidth: .infinity, alignment: .leading)
            AccessibleAnimatedView()
        }
        .padding()
    }
}
