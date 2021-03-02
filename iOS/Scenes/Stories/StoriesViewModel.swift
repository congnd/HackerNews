import RxSwift
import RxCocoa
import Domain

public final class StoriesViewModel: ViewModelType {
  struct Input {
    enum SortBy {
      case time
      case score
    }

    let viewDidLoad: ControlEvent<Void>
    let refresh: Observable<Void>
    let sort: PublishRelay<SortBy>
  }

  struct Output {
    let changes: Signal<(added: [IndexPath], removed: [IndexPath], updated: [IndexPath])>
    let reloadTableView: Signal<Void>
    let embeddedIndicator: Signal<Bool>
    let embeddedError: Signal<String?>
    let floatingError: Signal<String>
    let isRefreshing: Signal<Bool>
    let isSortAllowed: Driver<Bool>
  }

  private let storyService: StoryService

  var rows: [Story] = []

  private let disposeBag = DisposeBag()

  public init(storyService: StoryService) {
    self.storyService = storyService
  }

  func transform(_ input: Input) -> Output {
    let changes = PublishRelay<(added: [IndexPath], removed: [IndexPath], updated: [IndexPath])>()
    let reloadTableView = PublishRelay<Void>()
    let embeddedIndicator = PublishRelay<Bool>()
    let embeddedError = PublishRelay<String?>()
    let floatingError = PublishRelay<String>()
    let isRefreshing = PublishRelay<Bool>()
    let isSortAllowed = BehaviorRelay<Bool>(value: false)

    input.viewDidLoad.map { true }.bind(to: embeddedIndicator).disposed(by: disposeBag)
    input.viewDidLoad.map { nil }.bind(to: embeddedError).disposed(by: disposeBag)
    input.refresh.map { nil }.bind(to: embeddedError).disposed(by: disposeBag)

    Observable.merge(input.viewDidLoad.asObservable(), input.refresh)
      .flatMapLatest { self.fetchStories() }
      .subscribe(onNext: { result in
        switch result {
        case .success(let stories):
          self.rows = stories
          reloadTableView.accept(())
          isSortAllowed.accept(!self.rows.isEmpty)
        case .failure:
          let message = "Something went wrong \nPull to try again"
          if self.rows.isEmpty {
            embeddedError.accept(message)
          } else {
            floatingError.accept(message)
          }
        }
        embeddedIndicator.accept(false)
        isRefreshing.accept(false)
      })
      .disposed(by: disposeBag)

    input.sort
      .subscribe(onNext: { sortBy in
        switch sortBy {
        case .score:
          self.rows.sort { $0.score > $1.score }
        case .time:
          self.rows.sort { $0.time > $1.time }
        }
        reloadTableView.accept(())
        isSortAllowed.accept(!self.rows.isEmpty)
      })
      .disposed(by: disposeBag)

    return Output(
      changes: changes.asSignal(),
      reloadTableView: reloadTableView.asSignal(),
      embeddedIndicator: embeddedIndicator.asSignal(),
      embeddedError: embeddedError.asSignal(),
      floatingError: floatingError.asSignal(),
      isRefreshing: isRefreshing.asSignal(),
      isSortAllowed: isSortAllowed.asDriver())
  }
}

extension StoriesViewModel {
  func fetchStories() -> Observable<Result<[Story], Domain.Error>> {
    return .create { [weak self] observer -> Disposable in
      guard let self = self else { return Disposables.create() }
      self.storyService.fetchStories { result in
        observer.onNext(result)
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
