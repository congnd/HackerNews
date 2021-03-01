import RxSwift
import RxCocoa
import Domain

public final class StoriesViewModel: ViewModelType {
  struct Input {}
  struct Output {
    let reloadTableView: Signal<Void>
  }

  private let storyService: StoryService

  var rows: [Story] = []

  public init(storyService: StoryService) {
    self.storyService = storyService
    rows = (0..<50).map({ _ in
      Story(by: "", descendants: 123, id: 1, score: 123, time: Date(), title: "", url: URL(string: "https://google.com")!)
    })
  }

  func transform(_ input: Input) -> Output {
    let reloadTableView = PublishRelay<Void>()

    storyService.fetchStories { result in
      switch result {
      case .success(let stories):
        DispatchQueue.main.async {
          self.rows = stories
          reloadTableView.accept(())
        }
      case .failure: break
      }
    }

    return Output(reloadTableView: reloadTableView.asSignal())
  }
}
