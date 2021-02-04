import SwiftUI

public struct ECScrollView<Content: View>: View {

    private enum Constants {
        static var coordinateSpace: String { #function }
    }

    // MARK: - Private Properties

    @ObservedObject private var viewModel = ECScrollViewModel()

    /// Scroll view's content size
    @State private var contentSize = CGSize.zero

    /// Scroll view's content offset
    @State private var contentOffset = CGPoint.zero

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onContentOffsetChanged: ((CGSize, CGPoint) -> Void)?
    private let didEndDecelerating: (() -> Void)?
    private let content: Content

    // MARK: - Lifecycle

    public init(
        _ axes: Axis.Set,
        showsIndicators: Bool = true,
        onContentOffsetChanged: ((CGSize, CGPoint) -> Void)? = nil,
        didEndDecelerating: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onContentOffsetChanged = onContentOffsetChanged
        self.didEndDecelerating = didEndDecelerating
        self.content = content()
    }

    // MARK: - Public Properties

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack {
                content
                GeometryReader { geometry in
                    Color.clear.preference(key: ContentOffsetPreferenceKey.self, value: geometry.frame(in: .named(Constants.coordinateSpace)).origin)
                    Color.clear.preference(key: ContentSizePreferenceKey.self, value: geometry.size)
                }
            }
        }
        .coordinateSpace(name: Constants.coordinateSpace)
        .onPreferenceChange(ContentOffsetPreferenceKey.self) { contentOffset = $0 }
        .onPreferenceChange(ContentSizePreferenceKey.self) { contentSize = $0 }
        .onChange(of: contentOffset) {
            viewModel.scroll()
            onContentOffsetChanged?(contentSize, $0)
        }
        .onChange(of: contentSize) { onContentOffsetChanged?($0, contentOffset) }
        .onChange(of: viewModel.scrolling) { scrolling in
            guard !scrolling else { return }
            didEndDecelerating?()
        }
    }
}

// MARK: - Preference Keys

struct ContentOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let next = nextValue()
        value = CGPoint(
            x: value.x + -next.x,
            y: value.y + next.y
        )
    }
}

struct ContentSizePreferenceKey: PreferenceKey {
    typealias Value = CGSize

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
