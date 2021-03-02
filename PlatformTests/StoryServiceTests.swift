import XCTest
import Domain
import Platform
@testable import Api

private final class LogServiceMock: Domain.LogService {
  func info(category: LogCategory, _ message: String) {}
  func debug(category: LogCategory, _ message: String) {}
  func error(category: LogCategory, _ message: String) {}
}

class StoryServiceTests: XCTestCase {
  let storyIds = [0, 1, 2]
  let storyInfo = Api.Response.Story(
    by: "",
    descendants: nil,
    id: 0,
    score: 0,
    time: Date(),
    title: "",
    type: .story,
    url: nil)

  override func tearDown() {
    ApiLoaderMock.result = nil
    ApiLoaderMock.requestCount = 0
  }

  func test_loadStoryIdsFailure_producesError() {
    let sut = makeSut()

    ApiLoaderMock.result = .failure(.underlying)

    let exp = XCTestExpectation()

    sut.fetchStories { result in
      XCTAssertNil(try? result.get())
      XCTAssertEqual(ApiLoaderMock.requestCount, 1)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1)
  }

  func test_loadIdsOkButStoryInfoFailure_producesError() {
    let sut = makeSut()

    ApiLoaderMock.result = .success(storyIds)
    ApiLoaderMock.didReturn = { result in
      if self.storyIds == (try? result.get()) as? [Int] {
        ApiLoaderMock.result = .failure(.server)
      }
    }

    let exp = XCTestExpectation()

    sut.fetchStories { result in
      XCTAssertNil(try? result.get())
      XCTAssertEqual(ApiLoaderMock.requestCount, 4)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1)
  }

  func test_loadSuccess_producesData() {
    let sut = makeSut()

    ApiLoaderMock.result = .success(storyIds)
    ApiLoaderMock.didReturn = { result in
      if self.storyIds == (try? result.get()) as? [Int] {
        ApiLoaderMock.result = .success(self.storyInfo)
      }
    }

    let exp = XCTestExpectation()

    sut.fetchStories { result in
      XCTAssertEqual((try? result.get())?.count, 3)
      XCTAssertEqual(ApiLoaderMock.requestCount, 4)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1)
  }

  func makeSut() -> Platform.StoryService {
    return Platform.StoryService(apiLoader: ApiLoaderMock(), log: LogServiceMock())
  }
}
