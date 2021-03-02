import Foundation

extension Date {
  public var elapsedTime: String {
    let secondsAgo = max(1, Int(Date().timeIntervalSince(self)))
    let minute = 60
    let hour = 60 * minute
    let day = 24 * hour
    let week = 7 * day

    switch true {
    case secondsAgo < minute : return "\(secondsAgo)s"
    case secondsAgo < hour: return "\(secondsAgo / minute)m"
    case secondsAgo < day: return "\(secondsAgo / hour)h"
    case secondsAgo < week: return "\(secondsAgo / day)d"
    default:
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.calendar = .gregorian
      dateFormatter.timeZone = .jst
      dateFormatter.dateFormat = "yy/MM/dd"

      return dateFormatter.string(from: self)
    }
  }
}

public extension Calendar {
  static let gregorian = Calendar(identifier: .gregorian)
}

extension TimeZone {
  static let gmt = TimeZone(secondsFromGMT: 0)
  static let jst = TimeZone(secondsFromGMT: 32400)
}
