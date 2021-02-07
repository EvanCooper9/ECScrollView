import Combine
import CombineSchedulers
import SwiftUI

final class ECScrollViewModel: ObservableObject {

    let didScroll = PassthroughSubject<Void, Never>()
    @Published private(set) var scrolling = false

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?

    // MARK: - Lifecycle

    init(scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        let stopped = didScroll
            .map({ false })
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .eraseToAnyPublisher()

        let scrolling = didScroll
            .map({ true })
            .eraseToAnyPublisher()

        cancellable = scrolling
            .merge(with: stopped)
            .assign(to: \.scrolling, on: self)
    }
}
