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

    @State private var proxy: ScrollViewProxy?

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onContentOffsetChanged: ((CGPoint, CGSize, ScrollViewProxy) -> Void)?
    private let didEndDecelerating: ((CGPoint, ScrollViewProxy) -> Void)?
    private let content: Content

    // MARK: - Initializers

    public init(
        _ axes: Axis.Set,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        onContentOffsetChanged = nil
        didEndDecelerating = nil
        self.content = content()
    }

    private init(
        _ axes: Axis.Set,
        showsIndicators: Bool = true,
        onContentOffsetChanged: ((CGPoint, CGSize, ScrollViewProxy) -> Void)? = nil,
        didEndDecelerating: ((CGPoint, ScrollViewProxy) -> Void)? = nil,
        content: Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onContentOffsetChanged = onContentOffsetChanged
        self.didEndDecelerating = didEndDecelerating
        self.content = content
    }

    // MARK: - Public Properties

    public var body: some View {
        ScrollViewReader { proxy in
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
                viewModel.didScroll.send()
                onContentOffsetChanged?($0, contentSize, proxy)
            }
            .onChange(of: contentSize) {
                onContentOffsetChanged?(contentOffset, $0, proxy)
            }
            .onChange(of: viewModel.scrolling) { scrolling in
                guard !scrolling else { return }
                didEndDecelerating?(contentOffset, proxy)
            }
        }
    }

    public func didEndDecelerating(_ didEndDecelerating: @escaping (CGPoint, ScrollViewProxy) -> Void) -> Self {
        ECScrollView(
            axes,
            showsIndicators: showsIndicators,
            onContentOffsetChanged: onContentOffsetChanged,
            didEndDecelerating: didEndDecelerating,
            content: content
        )
    }

    public func onContentOffsetChanged(_ onContentOffsetChanged: @escaping (CGPoint, CGSize, ScrollViewProxy) -> Void) -> Self {
        ECScrollView(
            axes,
            showsIndicators: showsIndicators,
            onContentOffsetChanged: onContentOffsetChanged,
            didEndDecelerating: didEndDecelerating,
            content: content
        )
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
