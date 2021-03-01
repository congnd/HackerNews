import Foundation

enum Environment {
  case prod
  case qa
  case stg

  /// The current environment.
  /// This is determined based on the build configuration name for the current selected scheme.
  static let current: Environment = {
    let configurationName = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String
    if let configurationName = configurationName {
      if configurationName.contains("QA") {
        return .qa
      } else if configurationName.contains("STG") {
        return .stg
      }
    }
    return .prod
  }()
}
