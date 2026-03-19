// Example: Modern ScrollView-based Onboarding Flow
// iOS 18+ with backwards compatibility

import SwiftUI

// MARK: - Onboarding Data Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let accentColor: Color
}

// MARK: - Main Onboarding View (iOS 18+)

@available(iOS 18.0, *)
struct ModernOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var scrollPosition = ScrollPosition(idType: Int.self)

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome",
            description: "Discover amazing features that will transform your workflow.",
            systemImage: "hand.wave.fill",
            accentColor: .blue
        ),
        OnboardingPage(
            title: "Stay Organized",
            description: "Keep track of everything with smart lists and reminders.",
            systemImage: "checklist",
            accentColor: .green
        ),
        OnboardingPage(
            title: "Collaborate",
            description: "Share and work together with your team seamlessly.",
            systemImage: "person.2.fill",
            accentColor: .purple
        ),
        OnboardingPage(
            title: "Get Started",
            description: "You're all set! Let's begin your journey.",
            systemImage: "sparkles",
            accentColor: .orange
        )
    ]

    private var currentIndex: Int {
        scrollPosition.viewID ?? 0
    }

    private var isLastPage: Bool {
        currentIndex == pages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if !isLastPage {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding()

            // Pages
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition($scrollPosition)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)

            // Page indicator
            PageIndicator(currentIndex: currentIndex, totalPages: pages.count)
                .padding(.vertical)

            // Navigation buttons
            NavigationButtons(
                currentIndex: currentIndex,
                totalPages: pages.count,
                onNext: goToNextPage,
                onComplete: completeOnboarding
            )
            .padding()
        }
        .background(Color(.systemBackground))
    }

    private func goToNextPage() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            scrollPosition.scrollTo(id: currentIndex + 1)
        }
    }

    private func completeOnboarding() {
        hasCompleted = true
    }
}

// MARK: - Legacy Onboarding View (iOS 14-17)

struct LegacyOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome",
            description: "Discover amazing features that will transform your workflow.",
            systemImage: "hand.wave.fill",
            accentColor: .blue
        ),
        OnboardingPage(
            title: "Stay Organized",
            description: "Keep track of everything with smart lists and reminders.",
            systemImage: "checklist",
            accentColor: .green
        ),
        OnboardingPage(
            title: "Get Started",
            description: "You're all set! Let's begin your journey.",
            systemImage: "sparkles",
            accentColor: .orange
        )
    ]

    var body: some View {
        VStack {
            // Skip button
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        hasCompleted = true
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding()

            // TabView with page style
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Navigation button
            Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompleted = true
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 80))
                .foregroundStyle(page.accentColor)
                .accessibilityHidden(true)

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.description)")
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let currentIndex: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentIndex + 1) of \(totalPages)")
    }
}

// MARK: - Navigation Buttons

struct NavigationButtons: View {
    let currentIndex: Int
    let totalPages: Int
    let onNext: () -> Void
    let onComplete: () -> Void

    private var isLastPage: Bool {
        currentIndex == totalPages - 1
    }

    var body: some View {
        HStack {
            // Back button (hidden on first page)
            if currentIndex > 0 {
                Button {
                    // Go back
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Previous page")
            } else {
                // Placeholder for layout
                Button { } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.bordered)
                .hidden()
            }

            Spacer()

            // Main action button
            Button {
                if isLastPage {
                    onComplete()
                } else {
                    onNext()
                }
            } label: {
                Text(isLastPage ? "Get Started" : "Next")
                    .font(.headline)
                    .frame(minWidth: 140)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - App Entry Point with Onboarding

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false

    var body: some View {
        MainAppView()
            .fullScreenCover(isPresented: .constant(!hasCompleted)) {
                if #available(iOS 18.0, *) {
                    ModernOnboardingView()
                } else {
                    LegacyOnboardingView()
                }
            }
    }
}

struct MainAppView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Previews

#Preview("Modern Onboarding (iOS 18+)") {
    if #available(iOS 18.0, *) {
        ModernOnboardingView()
    }
}

#Preview("Legacy Onboarding") {
    LegacyOnboardingView()
}

#Preview("Page View") {
    OnboardingPageView(page: OnboardingPage(
        title: "Welcome",
        description: "Discover amazing features",
        systemImage: "hand.wave.fill",
        accentColor: .blue
    ))
}
