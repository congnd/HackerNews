import Domain

/// The log composer singleton class.
/// You use this to compose multiple log services into one
/// then you can use the composed log to pass arround.
/// This is helpful in case you have multiple loggers and want to use all of them.
public class LogServiceComposer: Domain.LogService {
  static public let shared = LogServiceComposer()

  var services: [LogService] = []

  public func register(service: LogService) {
    services.append(service)
  }

  public func info(category: LogCategory, _ message: String) {
    services.forEach { $0.info(category: category, message) }
  }

  public func debug(category: LogCategory, _ message: String) {
    services.forEach { $0.debug(category: category, message) }
  }

  public func error(category: LogCategory, _ message: String) {
    services.forEach { $0.error(category: category, message) }
  }
}
