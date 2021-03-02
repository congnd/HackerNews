import Domain
import Api

public final class StoryService: Domain.StoryService {
  public init() {}

  public func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
    Loader().request(target: Endpoint.TopStories()) { result in
      switch result {
      case .success(let ids):
        self.fetchStories(ids: Array(ids.prefix(50)), completion: completion)

      case .failure(let error):
        completion(.failure(.general(error.localizedDescription)))
      }
    }
  }

  func fetchStories(ids: [Int], completion: @escaping (Result<[Story], Error>) -> Void) {
    var stories: [Story] = []
    stories.reserveCapacity(500)
    var storyResponseCount = 0

    ids.forEach { id in
      Loader().request(target: Endpoint.Story(id: id)) { result in
        storyResponseCount += 1

        switch result {
        case .success(let story):
          stories.append(Story(from: story))
        case .failure(let error):
          print("Cong: \(error)")
        }

        if storyResponseCount == ids.count {
          if stories.count == ids.count {
            completion(.success(stories.sorted(by: { $0.time > $1.time })))
          } else {
            completion(.failure(.general("Could not fetch stories")))
          }
        }
      }
    }
  }
}

extension Story {
  init(from story: Api.Response.Story) {
    self = Story(
      by: story.by,
      descendants: story.descendants,
      id: story.id,
      score: story.score,
      time: story.time,
      title: story.title,
      url: story.url)
  }
}
