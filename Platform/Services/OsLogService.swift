import os
import Domain

/// A concrete implementation of log service using Apple's OS framework.
public class OsLogService: Domain.LogService {
  static public let shared = OsLogService()

  let bundleId = Bundle.main.bundleIdentifier ?? "com.hackernews"

  private init() {}

  public func info(category: LogCategory, _ message: String) {
    let log = OSLog(subsystem: bundleId, category: category.rawValue)
    os_log("%@", log: log, type: .info, message)
  }

  public func debug(category: LogCategory, _ message: String) {
    let log = OSLog(subsystem: bundleId, category: category.rawValue)
    os_log("%@", log: log, type: .debug, message)
  }

  public func error(category: LogCategory, _ message: String) {
    let log = OSLog(subsystem: bundleId, category: category.rawValue)
    os_log("%@", log: log, type: .error, message)
  }
}
