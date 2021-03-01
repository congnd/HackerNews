import Foundation

public class Configuration {
  public enum Environment {
    case prod
    case qa
    case stg
  }

  static public let shared = Configuration()

  /// Indicates which API environment we should send requests to.
  /// Set this to the desired one before firing any requests.
  public var environment: Environment = .prod

  /// Request timeout in seconds.
  public var timeout: Double = 10

  var domain: String {
    switch environment {
    case .prod, .qa, .stg:
      return "hacker-news.firebaseio.com"
    }
  }

  private init() {}
}
