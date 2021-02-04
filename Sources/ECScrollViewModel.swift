import Combine
import SwiftUI

final class ECScrollViewModel: ObservableObject {

    @Published private(set) var scrolling = false

    // MARK: - Private Properties

    private let didScroll = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?

    // MARK: - Lifecycle

    init() {
        let stopped = didScroll
            .map({ false })
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()

        let scrolling = didScroll
            .map({ true })
            .eraseToAnyPublisher()

        cancellable = scrolling
            .merge(with: stopped)
            .assign(to: \.scrolling, on: self)
    }

    // MARK: - Public Methods

    func scroll() {
        didScroll.send(())
    }
}
