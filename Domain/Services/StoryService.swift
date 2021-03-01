import Foundation

public protocol StoryService {
  func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void)
}
