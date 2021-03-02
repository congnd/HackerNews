import Domain

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
