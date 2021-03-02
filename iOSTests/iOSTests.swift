import XCTest
@testable import iOS

// swiftlint:disable type_name
class iOSTests: XCTestCase {
}

extension XCTestCase {
  func wait(_ second: Double) {
    let expectation = DelayExpectation(second)
    wait(for: [expectation], timeout: second + 0.05)
  }
}

fileprivate class DelayExpectation: XCTestExpectation {
  private let delay: Double

  init(_ delay: Double) {
    self.delay = delay
    super.init(description: "")
    start()
  }

  func start() {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      self?.fulfill()
    }
  }
}
