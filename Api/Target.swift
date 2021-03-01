import Foundation

public enum Method: String, CaseIterable {
  case get
  case post
  case delete
  case patch
}

/// A data type that represents nothing.
/// Use this data type when you don't expect anything from responses.
public struct Empty: Decodable {}

public protocol Target: Identifiable {
  associatedtype DataType: Decodable

  var id: UUID { get }
  var scheme: String { get }
  var host: String { get }
  var path: String { get }
  var params: [String: String] { get }
  var headers: [String: String] { get }
  var authorization: String? { get }
  var data: [String: String] { get }
  var method: Method { get }
}

public extension Target {
  var scheme: String { "http" }
  var host: String { Configuration.shared.domain }
  var params: [String: String] { [:] }
  var headers: [String: String] { [:] }
  var authorization: String? { nil }
  var data: [String: String] { [:] }
  var method: Method { .get }
}

extension Target {
  var urlString: String { "\(scheme)://\(host)\(path)\(queriesString)" }

  var queriesString: String {
    let queries = params
      .map({ "\($0)=\($1)" })
      .joined(separator: "&")

    return (queries.count > 0 ? "?\(queries)" : "")
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  }

  var urlRequest: URLRequest {
    let url = URL(string: urlString)!

    var urlRequest = URLRequest(url: url)
    urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    urlRequest.timeoutInterval = Configuration.shared.timeout
    urlRequest.allHTTPHeaderFields = headers
    urlRequest.httpMethod = method.rawValue

    if let authorization = authorization {
      urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
    }

    if data.count > 0 {
      urlRequest.httpBody = try? JSONEncoder().encode(data)
    }

    return urlRequest
  }
}

public struct SignedTarget<T: Target>: Target {
  public typealias DataType = T.DataType

  public var id: UUID { decoratee.id }
  public var scheme: String { decoratee.scheme }
  public var host: String { decoratee.host }
  public var path: String { decoratee.path }
  public var params: [String: String] { decoratee.params }
  public var headers: [String: String] { decoratee.headers }
  public var data: [String: String] { decoratee.data }
  public var method: Method { decoratee.method }

  public var authorization: String? { token }

  let decoratee: T
  let token: String?

  public init(_ decoratee: T, token: String) {
    self.decoratee = decoratee
    self.token = "Bearer \(token)"
  }
}
