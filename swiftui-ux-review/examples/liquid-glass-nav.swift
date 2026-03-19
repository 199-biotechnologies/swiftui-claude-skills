// Example: Proper Liquid Glass Navigation Implementation
// iOS 26+ with backwards compatibility

import SwiftUI

// MARK: - Adaptive Glass Modifier

struct AdaptiveGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(reduceTransparency ? .identity : .regular)
        } else {
            content
                .background(reduceTransparency ? Color(.systemBackground) : .ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

extension View {
    func adaptiveGlass() -> some View {
        modifier(AdaptiveGlassModifier())
    }
}

// MARK: - Main Tab View with Liquid Glass Tabs

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
        // iOS 26: Tab bar automatically uses Liquid Glass and shrinks on scroll
    }
}

// MARK: - Home View with Floating Action Button

struct HomeView: View {
    @State private var items: [Item] = Item.samples

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Content Layer - NO glass here
            List(items) { item in
                ItemRow(item: item)
            }
            .navigationTitle("Home")

            // Navigation Layer - Glass is appropriate here
            FloatingActionButton {
                // Add action
            }
            .padding()
        }
    }
}

// MARK: - Floating Action Button with Glass

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .adaptiveGlass()
        .accessibilityLabel("Add item")
        .accessibilityHint("Double tap to add a new item")
    }
}

// MARK: - Custom Toolbar with Coherent Glass

struct CustomToolbar: View {
    @Namespace private var glassNamespace

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                HStack(spacing: 16) {
                    ToolbarButton(icon: "square.and.arrow.up", label: "Share")
                        .glassEffectID("share", in: glassNamespace)

                    ToolbarButton(icon: "heart", label: "Favorite")
                        .glassEffectID("favorite", in: glassNamespace)

                    ToolbarButton(icon: "ellipsis", label: "More")
                        .glassEffectID("more", in: glassNamespace)
                }
                .padding(.horizontal)
            }
        } else {
            // Fallback for iOS 25 and earlier
            HStack(spacing: 16) {
                ToolbarButton(icon: "square.and.arrow.up", label: "Share")
                ToolbarButton(icon: "heart", label: "Favorite")
                ToolbarButton(icon: "ellipsis", label: "More")
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {
            // Action
        } label: {
            Image(systemName: icon)
                .font(.title3)
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Detail View with Sheet (Glass Applied Correctly)

struct DetailView: View {
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            // Content - no glass
            VStack(alignment: .leading, spacing: 16) {
                Image("header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Description goes here...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Toolbar uses system glass automatically in iOS 26
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            // Sheet uses system glass automatically
            ShareSheet()
        }
    }
}

// MARK: - Supporting Types

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String

    static let samples = [
        Item(title: "First Item", subtitle: "Description"),
        Item(title: "Second Item", subtitle: "Description"),
        Item(title: "Third Item", subtitle: "Description")
    ]
}

struct ItemRow: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            Text(item.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        // No glass on content rows
    }
}

struct SearchView: View {
    var body: some View {
        Text("Search")
            .navigationTitle("Search")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .navigationTitle("Profile")
    }
}

struct ShareSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button("Copy Link") { }
                Button("Share to Messages") { }
                Button("Share to Mail") { }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
