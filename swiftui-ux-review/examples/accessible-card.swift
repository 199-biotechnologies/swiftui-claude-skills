// Example: Fully Accessible Card Component
// Demonstrates VoiceOver, Dynamic Type, Reduce Motion, Color Contrast

import SwiftUI

// MARK: - Data Model

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Decimal
    let rating: Double
    let reviewCount: Int
    let imageName: String
    let isAvailable: Bool
}

// MARK: - Accessible Product Card

struct AccessibleProductCard: View {
    let product: Product
    var onFavorite: () -> Void = {}
    var onAddToCart: () -> Void = {}

    @State private var isFavorite = false
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    // Adapt layout for larger text sizes
    private var usesVerticalLayout: Bool {
        sizeCategory >= .accessibilityMedium
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with accessibility
            productImage

            // Content
            VStack(alignment: .leading, spacing: 8) {
                productTitle
                productDescription
                ratingView
                priceAndAvailability
            }
            .padding(.horizontal)

            // Actions
            actionButtons
                .padding([.horizontal, .bottom])
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        // Combined accessibility for the whole card
        .accessibilityElement(children: .contain)
    }

    // MARK: - Product Image

    private var productImage: some View {
        Image(product.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .clipped()
            // Decorative image - hide from VoiceOver since card has combined label
            .accessibilityHidden(true)
    }

    // MARK: - Product Title

    private var productTitle: some View {
        Text(product.name)
            .font(.headline)
            // Use semantic colors for contrast
            .foregroundStyle(.primary)
            // Ensure text scales properly
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Product Description

    private var productDescription: some View {
        Text(product.description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(usesVerticalLayout ? nil : 2)
    }

    // MARK: - Rating View

    private var ratingView: some View {
        HStack(spacing: 4) {
            // Star icon
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
                .accessibilityHidden(true)

            // Rating value
            Text(String(format: "%.1f", product.rating))
                .font(.subheadline)
                .fontWeight(.medium)

            // Review count
            Text("(\(product.reviewCount) reviews)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        // Combine into single accessibility element
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(String(format: "%.1f", product.rating)) stars from \(product.reviewCount) reviews")
    }

    // MARK: - Price and Availability

    private var priceAndAvailability: some View {
        HStack {
            // Price
            Text(product.price, format: .currency(code: "USD"))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Spacer()

            // Availability status
            availabilityBadge
        }
    }

    private var availabilityBadge: some View {
        HStack(spacing: 4) {
            // Color indicator
            Circle()
                .fill(product.isAvailable ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            // Icon for color-blind users
            if differentiateWithoutColor {
                Image(systemName: product.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(product.isAvailable ? .green : .red)
            }

            // Text label
            Text(product.isAvailable ? "In Stock" : "Out of Stock")
                .font(.caption)
                .foregroundStyle(product.isAvailable ? .green : .red)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(product.isAvailable ? "In stock" : "Out of stock")
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Group {
            if usesVerticalLayout {
                // Vertical layout for larger text
                VStack(spacing: 12) {
                    favoriteButton
                    addToCartButton
                }
            } else {
                // Horizontal layout for standard text
                HStack(spacing: 12) {
                    favoriteButton
                    addToCartButton
                }
            }
        }
    }

    private var favoriteButton: some View {
        Button {
            // Animate only if reduce motion is not enabled
            if reduceMotion {
                isFavorite.toggle()
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isFavorite.toggle()
                }
            }
            onFavorite()
        } label: {
            HStack {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : .primary)
                Text(isFavorite ? "Favorited" : "Favorite")
            }
            .frame(maxWidth: usesVerticalLayout ? .infinity : nil)
        }
        .buttonStyle(.bordered)
        // Accessibility
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to \(isFavorite ? "remove from" : "add to") favorites")
    }

    private var addToCartButton: some View {
        Button {
            onAddToCart()
        } label: {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("Add to Cart")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!product.isAvailable)
        // Accessibility
        .accessibilityLabel("Add to cart")
        .accessibilityHint(product.isAvailable ? "Double tap to add to cart" : "Item is out of stock")
    }
}

// MARK: - Product Card with Custom Actions

struct ProductCardWithActions: View {
    let product: Product
    @State private var isFavorite = false

    var body: some View {
        AccessibleProductCard(product: product)
            // Add custom VoiceOver actions
            .accessibilityAction(named: "Toggle favorite") {
                isFavorite.toggle()
            }
            .accessibilityAction(named: "View details") {
                // Navigate to details
            }
            .accessibilityAction(named: "Share") {
                // Share product
            }
    }
}

// MARK: - Loading State Card

struct LoadingProductCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder image
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 200)

            VStack(alignment: .leading, spacing: 8) {
                // Placeholder title
                Text("Product Name Here")
                    .font(.headline)

                // Placeholder description
                Text("Product description goes here with details")
                    .font(.subheadline)

                // Placeholder rating
                HStack {
                    Image(systemName: "star.fill")
                    Text("4.5 (100)")
                }
                .font(.caption)

                // Placeholder price
                Text("$99.99")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        // Apply redacted/skeleton effect
        .redacted(reason: .placeholder)
        // Accessibility for loading state
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading product")
    }
}

// MARK: - Card List with States

struct ProductListView: View {
    enum LoadingState {
        case loading
        case loaded([Product])
        case empty
        case error(String)
    }

    @State private var state: LoadingState = .loading

    var body: some View {
        NavigationStack {
            Group {
                switch state {
                case .loading:
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                LoadingProductCard()
                            }
                        }
                        .padding()
                    }

                case .loaded(let products):
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(products) { product in
                                AccessibleProductCard(product: product)
                            }
                        }
                        .padding()
                    }

                case .empty:
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "bag.badge.questionmark",
                        description: Text("Check back later for new arrivals")
                    )

                case .error(let message):
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    ) {
                        Button("Try Again") {
                            loadProducts()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Products")
        }
        .onAppear {
            loadProducts()
        }
    }

    private func loadProducts() {
        state = .loading
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            state = .loaded(Product.samples)
        }
    }
}

// MARK: - Sample Data

extension Product {
    static let samples = [
        Product(
            name: "Wireless Headphones",
            description: "Premium noise-canceling headphones with 30-hour battery life.",
            price: 299.99,
            rating: 4.8,
            reviewCount: 1234,
            imageName: "headphones",
            isAvailable: true
        ),
        Product(
            name: "Smart Watch",
            description: "Track your fitness and stay connected with this sleek smart watch.",
            price: 399.99,
            rating: 4.5,
            reviewCount: 867,
            imageName: "watch",
            isAvailable: true
        ),
        Product(
            name: "Portable Speaker",
            description: "Waterproof Bluetooth speaker with 360-degree sound.",
            price: 149.99,
            rating: 4.2,
            reviewCount: 543,
            imageName: "speaker",
            isAvailable: false
        )
    ]
}

// MARK: - Previews

#Preview("Standard Size") {
    ScrollView {
        AccessibleProductCard(product: Product.samples[0])
            .padding()
    }
}

#Preview("Large Text") {
    ScrollView {
        AccessibleProductCard(product: Product.samples[0])
            .padding()
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
}

#Preview("Differentiate Without Color") {
    ScrollView {
        AccessibleProductCard(product: Product.samples[2])
            .padding()
    }
    .environment(\.accessibilityDifferentiateWithoutColor, true)
}

#Preview("Loading State") {
    ScrollView {
        LoadingProductCard()
            .padding()
    }
}

#Preview("Product List") {
    ProductListView()
}
