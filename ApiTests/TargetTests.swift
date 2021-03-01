import XCTest
@testable import Api

class ApiTargetTests: XCTestCase {
  func test_targetInit_properTimeoout() {
    let sut = TargetStub()

    XCTAssertEqual(sut.urlRequest.timeoutInterval, Configuration.shared.timeout)
  }

  func test_targetInit_properCachePolicy() {
    let sut = TargetStub()

    XCTAssertEqual(sut.urlRequest.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
  }

  func test_targetWithSchemeAndHostOnly_producesProperUrl() {
    let sut = TargetStub()

    XCTAssertEqual(sut.urlRequest.url!.absoluteString, "https://example.com")
  }

  func test_targetWithPath_producesProperUrl() {
    let sut = TargetStub(path: "/path/to/")

    XCTAssertEqual(sut.urlRequest.url!.absoluteString, "https://example.com/path/to/")
  }

  func test_targetWithPathParams_producesProperUrl() {
    let sut = TargetStub(path: "/path/to/", params: ["p": "a space"])

    XCTAssertEqual(sut.urlRequest.url!.absoluteString, "https://example.com/path/to/?p=a%20space")
  }

  func test_targetWithHeaderAndData_doesNotChangeTheOutputUrl() {
    let sut = TargetStub(
      path: "/path/to/",
      params: ["p": "a space"],
      headers: ["authorization": "OAuth2 123"],
      data: ["key": "value"])

    XCTAssertEqual(sut.urlRequest.url!.absoluteString, "https://example.com/path/to/?p=a%20space")
  }

  func test_targetWithAuthorization_producesRequestWithAuthorization() {
    let inputAuthorization = "OAuth2 12345"
    let sut = TargetStub(authorization: inputAuthorization)

    let outputAuthorization = sut.urlRequest.value(forHTTPHeaderField: "Authorization")

    XCTAssertEqual(inputAuthorization, outputAuthorization)
  }

  func test_targetWithHeaders_producesRequestWithProperHeaders() {
    let inputHeaders = ["k1": "v1", "k2": "v2"]
    let sut = TargetStub(headers: inputHeaders)

    let outputHeaders = sut.urlRequest.allHTTPHeaderFields

    XCTAssertEqual(inputHeaders, outputHeaders)
  }

  func test_targetWithData_producesRequestWithData() {
    let inputData = ["k1": "v1", "k2": "v2"]
    let sut = TargetStub(data: inputData)
    let outputDataString = String(data: sut.urlRequest.httpBody!, encoding: .utf8)

    XCTAssertTrue([
      "{\"k2\":\"v2\",\"k1\":\"v1\"}",
      "{\"k1\":\"v1\",\"k2\":\"v2\"}",
    ].contains(outputDataString))
  }

  func test_targetWithMethod_producesRequestWithHttpMethod() {
    Api.Method.allCases.forEach {
      XCTAssertEqual(
        $0.rawValue.uppercased(),
        TargetStub(method: $0).urlRequest.httpMethod?.uppercased())
    }
  }
}
