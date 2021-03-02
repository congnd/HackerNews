import Foundation

public protocol StoryService {
  /// Fetch top stories
  func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void)
}
