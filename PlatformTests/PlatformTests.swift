import XCTest
import Api
@testable import Platform

class PlatformTests: XCTestCase {
}

final class ApiLoaderMock: LoaderProtocol {
  static var result: Result<Decodable, LoaderError>?
  static var didReturn: (Result<Decodable, LoaderError>) -> Void = { _ in }
  static var requestCount = 0

  func request<T>(
    target: T,
    completion: @escaping (Result<T.DataType, LoaderError>) -> Void
  ) -> CancellableRequest where T: Target {
    Self.requestCount += 1
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      if let result = Self.result {
        do {
          let data = try result.get()
          if let data = data as? T.DataType {
            completion(.success(data))
            Self.didReturn(result)
          } else {
            XCTFail("Data type does not match")
          }
        } catch let error as LoaderError {
          completion(.failure(error))
          Self.didReturn(result)
        } catch {
          XCTFail("Unknown error")
        }
      } else {
        XCTFail("No mock response provided")
      }
    }

    return CancellableRequestMock()
  }
}

final class CancellableRequestMock: CancellableRequest {
  static var callCount = 0

  func cancel() {
    Self.callCount += 1
  }
}
