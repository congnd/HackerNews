import Foundation

fileprivate let errorDomain = "com.congnd.hackernews"

public let emptyResponseError = NSError(
  domain: errorDomain,
  code: 0,
  userInfo: ["error": "No required data found in the response."])

public protocol CancellableRequest {
  func cancel()
}

extension URLSessionTask: CancellableRequest {}

public protocol LoaderProtocol {
  @discardableResult
  func request<T: Target>(
    target: T,
    completion: @escaping (Result<T.DataType, LoaderError>) -> Void
  ) -> CancellableRequest
}

public final class Loader: LoaderProtocol {
  private let urlSession: URLSession

  private lazy var jsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    jsonDecoder.dateDecodingStrategy = .secondsSince1970
    return jsonDecoder
  }()

  public init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }

  @discardableResult
  public func request<T: Target>(
    target: T,
    completion: @escaping (Result<T.DataType, LoaderError>) -> Void
  ) -> CancellableRequest {
    let task = urlSession.dataTask(with: target.urlRequest) { data, res, error in
      if let statusCode = (res as? HTTPURLResponse)?.statusCode, statusCode != 200 {
        switch statusCode {
        case 500...: completion(.failure(.server))
        case 400...: completion(.failure(.unauthorized))
        default: completion(.failure(.underlying))
        }
        return
      }

      guard let data = data else {
        completion(.failure(self.parse(error: error)))
        return
      }

      do {
        let responseData = try self.jsonDecoder.decode(T.DataType.self, from: data)

        completion(.success(responseData))
      } catch {
        completion(.failure(.invalidResponse(error)))
      }
    }

    task.resume()
    return task
  }
}

private extension Loader {
  func parse(error: Error?) -> LoaderError {
    if
      let error = error as NSError?,
      error.domain == NSURLErrorDomain,
      error.code == NSURLErrorCancelled
    {
      return .cancelled
    } else {
      return .underlying
    }
  }
}
