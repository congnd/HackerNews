import XCTest
@testable import Api

class URLProtocolStub: URLProtocol {
  static var data: Data?
  static let error = NSError(domain: "", code: 0, userInfo: nil)

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
      if let data = Self.data {
        self.client?.urlProtocol(self, didLoad: data)
      } else {
        self.client?.urlProtocol(self, didFailWithError: Self.error)
      }

      self.client?.urlProtocolDidFinishLoading(self)
    }
  }

  override func stopLoading() { }
}

// MARK: - Non-Paging Target Tests

class ApiLoaderTests: XCTestCase {
  func test_loadFailure_producesResultWithProperError() {
    URLProtocolStub.data = nil

    let expectation = XCTestExpectation()

    fireRequest(TargetStub()) { data, error in
      XCTAssertNil(data)
      XCTAssertEqual(error, .underlying)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.1)
  }

  func test_loadInvalidResponse_producesResultWithProperError() {
    let jsonString = """
    {
      "data": 123
    }
    """
    URLProtocolStub.data = jsonString.data(using: .utf8)

    let expectation = XCTestExpectation()

    fireRequest(TargetStub()) { data, error in
      XCTAssertNil(data)
      if case .invalidResponse = error {
        expectation.fulfill()
      } else {
        XCTFail("Expected an invalidResponse error instead")
      }
    }

    wait(for: [expectation], timeout: 0.1)
  }

  func test_loadValidResponse_producesResultWithData() {
    let jsonString = """
    {
      "user_name": "user name",
      "date": 1614594716
    }
    """
    URLProtocolStub.data = jsonString.data(using: .utf8)

    let expectation = XCTestExpectation()

    fireRequest(TargetStub()) { data, error in
      XCTAssertNil(error)
      XCTAssertEqual(data?.userName, "user name")
      XCTAssertEqual(data?.date, Date(timeIntervalSince1970: 1614594716))
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.1)
  }

  func test_incorrectDateFormat_producesResultWithError() {
    let jsonString = """
    {
      "user_name": "user name",
      "date": "2021-03-01 22:29:26"
    }
    """
    URLProtocolStub.data = jsonString.data(using: .utf8)

    let expectation = XCTestExpectation()

    fireRequest(TargetStub()) { data, error in
      XCTAssertNil(data)
      if case .invalidResponse = error {
        expectation.fulfill()
      } else {
        XCTFail("Expected an invalidResponse error instead")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.1)
  }

  func test_cancelRequest_producesCancelledResponse() {
    let expectation = XCTestExpectation()

    let request = fireRequest(TargetStub()) { response, error in
      XCTAssertNil(response)
      XCTAssertEqual(error, .cancelled)
      expectation.fulfill()
    }
    request.cancel()

    wait(for: [expectation], timeout: 0.1)
  }

  @discardableResult
  func fireRequest<T: Target>(
    _ target: T,
    completion: @escaping (T.DataType?, LoaderError?) -> Void
  ) -> CancellableRequest {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [URLProtocolStub.self]

    let urlSessionSpy = URLSession(configuration: config)

    let apiLoader = Loader(urlSession: urlSessionSpy)

    return apiLoader.request(target: target) { result in
      switch result {
      case let .failure(err):
        completion(nil, err)
      case let .success(res):
        completion(res, nil)
      }
    }
  }
}
