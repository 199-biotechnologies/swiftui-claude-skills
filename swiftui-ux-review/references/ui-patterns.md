# SwiftUI UI Patterns Reference

## Navigation Patterns

### NavigationStack (iOS 16+)

The modern navigation approach replaces NavigationView:

```swift
struct MainView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ContentView()
                .navigationDestination(for: Item.self) { item in
                    ItemDetailView(item: item)
                }
                .navigationDestination(for: Category.self) { category in
                    CategoryView(category: category)
                }
        }
    }
}
```

### Tab-Based Navigation

Each tab maintains its own navigation stack:

```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(2)
        }
    }
}
```

### Coordinator Pattern

For complex navigation flows:

```swift
@Observable
class AppCoordinator {
    var homePath = NavigationPath()
    var searchPath = NavigationPath()
    var profilePath = NavigationPath()

    func navigateToItemDetail(_ item: Item, from tab: Tab) {
        switch tab {
        case .home:
            homePath.append(item)
        case .search:
            searchPath.append(item)
        case .profile:
            profilePath.append(item)
        }
    }

    func popToRoot(tab: Tab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .search:
            searchPath = NavigationPath()
        case .profile:
            profilePath = NavigationPath()
        }
    }
}
```

## Onboarding Patterns

### Modern ScrollView Approach (iOS 18+)

Preferred over TabView for iOS 18+:

```swift
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var scrollPosition = ScrollPosition(idType: Int.self)

    private let pages = [
        OnboardingPage(title: "Welcome", description: "Get started with our app", image: "hand.wave"),
        OnboardingPage(title: "Discover", description: "Explore amazing features", image: "sparkles"),
        OnboardingPage(title: "Connect", description: "Share with friends", image: "person.2")
    ]

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
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
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(scrollPosition.viewID == index ? .primary : .secondary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()

            // Navigation buttons
            HStack {
                if let current = scrollPosition.viewID, current > 0 {
                    Button("Back") {
                        withAnimation {
                            scrollPosition.scrollTo(id: current - 1)
                        }
                    }
                }

                Spacer()

                if let current = scrollPosition.viewID, current < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            scrollPosition.scrollTo(id: current + 1)
                        }
                    }
                } else {
                    Button("Get Started") {
                        hasCompleted = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
```

### TabView Approach (iOS 14-17)

For backwards compatibility:

```swift
struct LegacyOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<3) { index in
                OnboardingPageView(index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .overlay(alignment: .bottom) {
            Button(currentPage == 2 ? "Get Started" : "Next") {
                if currentPage < 2 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompleted = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 60)
        }
    }
}
```

### Presenting Over Tab Bar

```swift
struct ContentView: View {
    @AppStorage("showOnboarding") private var showOnboarding = true

    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
    }
}
```

## Sheet and Modal Patterns

### Basic Sheet

```swift
struct ItemListView: View {
    @State private var selectedItem: Item?
    @State private var showingAddSheet = false

    var body: some View {
        List(items) { item in
            ItemRow(item: item)
                .onTapGesture {
                    selectedItem = item
                }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailSheet(item: item)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
        }
    }
}
```

### Presentation Detents (iOS 16+)

```swift
struct DetailSheet: View {
    var body: some View {
        VStack {
            // Content
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}
```

### Controlled Dismissal

```swift
struct EditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasChanges = false

    var body: some View {
        Form {
            // Edit fields
        }
        .interactiveDismissDisabled(hasChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
                .disabled(!hasChanges)
            }
        }
    }
}
```

### Sheet Attached to Container (Best Practice)

```swift
// ✅ Correct: Sheet attached to outermost view
struct CorrectSheetExample: View {
    @State private var showSheet = false

    var body: some View {
        VStack {
            Button("Show") {
                showSheet = true
            }
        }
        .sheet(isPresented: $showSheet) {  // Attached to VStack
            SheetContent()
        }
    }
}

// ❌ Wrong: Sheet attached to button
struct WrongSheetExample: View {
    @State private var showSheet = false

    var body: some View {
        VStack {
            Button("Show") {
                showSheet = true
            }
            .sheet(isPresented: $showSheet) {  // Attached to Button - can cause issues
                SheetContent()
            }
        }
    }
}
```

## Form Patterns

### Settings Screen

```swift
struct SettingsView: View {
    @AppStorage("notifications") private var notifications = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("fontSize") private var fontSize = 14.0

    var body: some View {
        Form {
            Section("Preferences") {
                Toggle("Notifications", isOn: $notifications)
                Toggle("Dark Mode", isOn: $darkMode)
            }

            Section("Appearance") {
                Slider(value: $fontSize, in: 12...24) {
                    Text("Font Size")
                }
                Text("Preview text")
                    .font(.system(size: fontSize))
            }

            Section {
                Button("Reset to Defaults", role: .destructive) {
                    resetDefaults()
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

### Form Validation

```swift
struct SignupForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    private var isPasswordValid: Bool {
        password.count >= 8
    }

    private var passwordsMatch: Bool {
        password == confirmPassword
    }

    private var canSubmit: Bool {
        isEmailValid && isPasswordValid && passwordsMatch
    }

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                if !email.isEmpty && !isEmailValid {
                    Text("Please enter a valid email")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)

                if !password.isEmpty && !isPasswordValid {
                    Text("Password must be at least 8 characters")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                SecureField("Confirm Password", text: $confirmPassword)

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords do not match")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section {
                Button("Create Account") {
                    submit()
                }
                .disabled(!canSubmit)
            }
        }
    }
}
```

## Loading State Patterns

### Enum-Based State Management

```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)
}

struct ItemListView: View {
    @State private var state: LoadingState<[Item]> = .idle

    var body: some View {
        Group {
            switch state {
            case .idle:
                Color.clear.onAppear { load() }

            case .loading:
                SkeletonListView()

            case .loaded(let items):
                List(items) { item in
                    ItemRow(item: item)
                }

            case .empty:
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray",
                    description: Text("Add items to get started")
                )

            case .error(let error):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                ) {
                    Button("Retry") { load() }
                }
            }
        }
    }
}
```

### Skeleton Loading with Redacted

```swift
struct SkeletonListView: View {
    var body: some View {
        List {
            ForEach(0..<5) { _ in
                ItemRowPlaceholder()
                    .redacted(reason: .placeholder)
            }
        }
    }
}

struct ItemRowPlaceholder: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text("Placeholder Title Here")
                    .font(.headline)
                Text("Subtitle placeholder text")
                    .font(.subheadline)
            }
        }
    }
}
```

### ContentUnavailableView (iOS 17+)

```swift
// Search empty state
ContentUnavailableView.search(text: searchText)

// Custom empty state
ContentUnavailableView(
    "No Favorites",
    systemImage: "heart.slash",
    description: Text("Items you favorite will appear here")
)

// With action
ContentUnavailableView(
    "No Connection",
    systemImage: "wifi.slash",
    description: Text("Check your internet connection")
) {
    Button("Try Again") {
        retry()
    }
    .buttonStyle(.bordered)
}
```

## Card Patterns

### App Store Style Card

```swift
struct ExpandableCard: View {
    let item: Item
    @Namespace private var animation
    @State private var isExpanded = false

    var body: some View {
        if isExpanded {
            ExpandedCardView(item: item, namespace: animation) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isExpanded = false
                }
            }
        } else {
            CompactCardView(item: item, namespace: animation)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
        }
    }
}

struct CompactCardView: View {
    let item: Item
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading) {
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .matchedGeometryEffect(id: "image-\(item.id)", in: namespace)

            Text(item.title)
                .font(.headline)
                .matchedGeometryEffect(id: "title-\(item.id)", in: namespace)
                .padding()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

## Animation Patterns

### Spring Animations

```swift
// Standard interactive spring
withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
    isExpanded.toggle()
}

// Bouncy spring
withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
    scale = 1.2
}

// Smooth spring
withAnimation(.spring(response: 0.6, dampingFraction: 1.0)) {
    offset = 0
}
```

### Transition Animations

```swift
struct AnimatedListItem: View {
    var body: some View {
        ItemContent()
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
    }
}
```

## External Resources

- [SwiftUI Navigation 2025](https://medium.com/@sunnygulatiios/mastering-swiftui-navigation-in-2025-coordinators-mvvm-tab-bars-6eb34d440940)
- [Building Better Onboarding Flow](https://www.riveralabs.com/blog/swiftui-onboarding/)
- [SwiftUI Sheets Guide](https://www.swiftyplace.com/blog/swiftui-sheets-modals-bottom-sheets-fullscreen-presentation-in-ios)
- [SwiftUI Forms Guide](https://bugfender.com/blog/swiftui-forms/)
- [Handling Loading States](https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/)
- [App Store Card Animations](https://medium.com/@charithgunasekera/crafting-app-store-style-card-animations-with-swiftui-12cc3257928e)
