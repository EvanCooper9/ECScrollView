import Combine
import CombineSchedulers
import XCTest

@testable import ECScrollView

final class ECScrollViewTest: XCTestCase {

    private var testScheduler: TestSchedulerOf<DispatchQueue>!
    private var viewModel: ECScrollViewModel!

    override func setUp() {
        super.setUp()
        testScheduler = DispatchQueue.testScheduler
        viewModel = ECScrollViewModel(scheduler: testScheduler.eraseToAnyScheduler())
    }

    func testThatDidScrollTriggersScrolling() {
        XCTAssertFalse(viewModel.scrolling)
        viewModel.didScroll.send()
        XCTAssertTrue(viewModel.scrolling)
    }

    func testThatScrollingIsFalseAfterSomeTime() {
        XCTAssertFalse(viewModel.scrolling)
        viewModel.didScroll.send()
        XCTAssertTrue(viewModel.scrolling)
        testScheduler.advance(by: 0.5)
        XCTAssertFalse(viewModel.scrolling)
    }
}
