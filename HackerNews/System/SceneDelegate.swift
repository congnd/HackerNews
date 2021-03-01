import UIKit
import iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let coordinator = StoriesCoordinator(navigationController: UINavigationController())
    let appContainer = AppContainerController(coordinator: coordinator)

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = appContainer
    window?.makeKeyAndVisible()
  }
}
