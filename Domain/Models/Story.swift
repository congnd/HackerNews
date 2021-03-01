import Foundation

public struct Story {
  public let by: String
  public let descendants: Int?
  public let id: Int
  public let score: Int
  public let time: Date
  public let title: String
  public let url: URL?

  public init(
    by: String,
    descendants: Int?,
    id: Int,
    score: Int,
    time: Date,
    title: String,
    url: URL?
  ) {
    self.by = by
    self.descendants = descendants
    self.id = id
    self.score = score
    self.time = time
    self.title = title
    self.url = url
  }
}
