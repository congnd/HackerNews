import XCTest
import Domain
import RxSwift
import RxCocoa
@testable import iOS

let storyInfo = Story(by: "", descendants: nil, id: 0, score: 0, time: Date(), title: "", url: nil)

class StoryViewModelTests: XCTestCase {
  // swiftlint:disable function_body_length

  /// 1. load stories success with non-empty stories
  /// 2. refresh success with non-empty stories
  /// 3. refresh failed
  /// 4. refresh success with empty stories
  func test_scenario1() {
    let sut = makeSut()

    let viewDidLoad = PublishRelay<Void>()
    let refresh = PublishRelay<Void>()
    let sort = PublishRelay<StoriesViewModel.Input.SortBy>()

    let input = StoriesViewModel.Input(
      viewDidLoad: ControlEvent(events: viewDidLoad),
      refresh: refresh.asObservable(),
      sort: sort)

    let output = sut.transform(input)

    let changesSpied = ObservableValueSpy(output.changes.asObservable())
    let reloadTableViewSpied = ObservableValueSpy(output.reloadTableView.asObservable())
    let embeddedErrorSpied = ObservableValueSpy(output.embeddedError.asObservable())
    let embeddedIndicatorSpied = ObservableValueSpy(output.embeddedIndicator.asObservable())
    let floatingErrorSpied = ObservableValueSpy(output.floatingError.asObservable())
    let isRefreshingSpied = ObservableValueSpy(output.isRefreshing.asObservable())
    let isSortAllowedSpied = ObservableValueSpy(output.isSortAllowed.asObservable())

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 0)
    XCTAssertEqual(embeddedErrorSpied.values.count, 0)
    XCTAssertEqual(embeddedIndicatorSpied.values.count, 0)
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values.count, 0)
    XCTAssertEqual(isSortAllowedSpied.values.count, 1)

    StoryServiceMock.result = .success([storyInfo])
    viewDidLoad.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 1)
    XCTAssertEqual(embeddedErrorSpied.values, [nil])
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values, [false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true])

    StoryServiceMock.result = .success([storyInfo])
    refresh.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 2)
    XCTAssertEqual(embeddedErrorSpied.values, [nil, nil])
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values, [false, false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true, true])

    StoryServiceMock.result = .failure(.general(""))
    refresh.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 2)
    XCTAssertEqual(embeddedErrorSpied.values, [nil, nil, nil])
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false, false, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 1)
    XCTAssertEqual(isRefreshingSpied.values, [false, false, false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true, true])

    StoryServiceMock.result = .success([])
    refresh.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 3)
    XCTAssertEqual(embeddedErrorSpied.values, [nil, nil, nil, nil])
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false, false, false, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 1)
    XCTAssertEqual(isRefreshingSpied.values, [false, false, false, false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true, true, false])
  }

  /// 1. load stories failure
  /// 2. refresh success with non-empty stories
  /// 3. change sort order
  func test_scenario2() {
    let sut = makeSut()

    let viewDidLoad = PublishRelay<Void>()
    let refresh = PublishRelay<Void>()
    let sort = PublishRelay<StoriesViewModel.Input.SortBy>()

    let input = StoriesViewModel.Input(
      viewDidLoad: ControlEvent(events: viewDidLoad),
      refresh: refresh.asObservable(),
      sort: sort)

    let output = sut.transform(input)

    let changesSpied = ObservableValueSpy(output.changes.asObservable())
    let reloadTableViewSpied = ObservableValueSpy(output.reloadTableView.asObservable())
    let embeddedErrorSpied = ObservableValueSpy(output.embeddedError.asObservable())
    let embeddedIndicatorSpied = ObservableValueSpy(output.embeddedIndicator.asObservable())
    let floatingErrorSpied = ObservableValueSpy(output.floatingError.asObservable())
    let isRefreshingSpied = ObservableValueSpy(output.isRefreshing.asObservable())
    let isSortAllowedSpied = ObservableValueSpy(output.isSortAllowed.asObservable())

    StoryServiceMock.result = .failure(.general(""))
    viewDidLoad.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 0)
    XCTAssertEqual(embeddedErrorSpied.values.count, 2)
    XCTAssertNotNil(embeddedErrorSpied.values.last!)
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values, [false])
    XCTAssertEqual(isSortAllowedSpied.values, [false])

    StoryServiceMock.result = .success([storyInfo])
    refresh.accept(())

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 1)
    XCTAssertEqual(embeddedErrorSpied.values.count, 3)
    XCTAssertNil(embeddedErrorSpied.values.last!)
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values, [false, false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true])

    sort.accept(.score)

    wait(0.1)

    XCTAssertEqual(changesSpied.values.count, 0)
    XCTAssertEqual(reloadTableViewSpied.values.count, 2)
    XCTAssertEqual(embeddedErrorSpied.values.count, 3)
    XCTAssertNil(embeddedErrorSpied.values.last!)
    XCTAssertEqual(embeddedIndicatorSpied.values, [true, false, false])
    XCTAssertEqual(floatingErrorSpied.values.count, 0)
    XCTAssertEqual(isRefreshingSpied.values, [false, false])
    XCTAssertEqual(isSortAllowedSpied.values, [false, true, true])
  }

  func makeSut() -> StoriesViewModel {
    return StoriesViewModel(storyService: StoryServiceMock())
  }
}

final class StoryServiceMock: Domain.StoryService {
  static var result: Result<[Story], Error>?

  func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
    DispatchQueue.main.async {
      if let result = Self.result {
        completion(result)
      } else {
        XCTFail("No mock response provided")
      }
    }
  }
}

class ObservableValueSpy<T> {
  private(set) var values: [T] = []
  private var disposeBag = DisposeBag()

  init(_ observable: Observable<T>) {
    observable.subscribe(onNext: { [weak self] state in
      self?.values.append(state)
    })
    .disposed(by: disposeBag)
  }
}
