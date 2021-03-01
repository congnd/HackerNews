import Foundation

public enum LoaderError: Swift.Error {
  case underlying
  case server
  case unauthorized
  case cancelled
  case invalidResponse(Error)
}

extension LoaderError: Equatable {
  public static func == (lhs: LoaderError, rhs: LoaderError) -> Bool {
    switch (lhs, rhs) {
    case (.underlying, .underlying): return true
    case (.server, .server): return true
    case (.unauthorized, .unauthorized): return true
    case (.cancelled, .cancelled): return true
    case (.invalidResponse(let le), invalidResponse(let re)):
      return le.localizedDescription == re.localizedDescription
    case (.underlying, _), (.invalidResponse, _), (.cancelled, _), (.server, _), (.unauthorized, _):
      return false
    }
  }
}
