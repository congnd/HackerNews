import Foundation

public enum Response {
  public struct Story: Decodable {
    public enum `Type`: String, Decodable {
      case job
      case story
      case comment
      case poll
      case pollopt
    }
    public let by: String
    public let descendants: Int
    public let id: Int
    public let kids: [Int]
    public let score: Int
    public let time: Date
    public let title: String
    public let type: Type
    public let url: URL
  }
}
