import Foundation

public enum Endpoint {
  public struct TopStories: Target {
    public typealias DataType = [Int]

    public var id = UUID()
    public let path = "/v0/topstories.json"

    public init() {}
  }

  public struct Story: Target {
    public typealias DataType = Response.Story

    public var id = UUID()
    public var path = "/v0/item/%d.json"

    public init(id: Int) {
      path = String(format: path, id)
    }
  }
}
