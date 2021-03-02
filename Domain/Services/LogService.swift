import Foundation

public enum LogCategory: String {
  /// The default.
  case general

  case auth
  case api
}

public protocol LogService {
  /// Use this level to capture information that may be helpful,
  /// but not essential, for troubleshooting errors.
  /// - Parameters:
  ///   - message: The message to be logged
  func info(category: LogCategory, _ message: String)

  /// Messages are intended for use in a development environment while actively debugging.
  /// - Parameters:
  ///   - message: The message to be logged
  func debug(category: LogCategory, _ message: String)

  /// Messages are intended for reporting critical errors and failures.
  /// - Parameters:
  ///   - message: The message to be logged
  func error(category: LogCategory, _ message: String)
}
