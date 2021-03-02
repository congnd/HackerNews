import UIKit
import iOS
import Platform
import SafariServices

final class StoriesCoordinator: NSObject, Coordinator {
  var childCoordinators = [Coordinator]()
  var navigationController: UINavigationController
  weak var rootViewController: UIViewController?

  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
    super.init()
    navigationController.navigationBar.isHidden = true
  }

  func start() {
    let home = StoriesViewController(
      coordinator: self,
      viewModel: StoriesViewModel(storyService: StoryService()))
    navigationController.viewControllers = [home]
  }
}

extension StoriesCoordinator: StoriesCoordinating {
  func navigateToBrowser(url: URL) {
    let browser = SFSafariViewController(url: url)
    browser.dismissButtonStyle = .close
    navigationController.present(browser, animated: true)
  }
}
