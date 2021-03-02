import UIKit
import iOS
import Platform

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    configureLogServices()

    let coordinator = StoriesCoordinator(navigationController: UINavigationController())
    let appContainer = AppContainerController(coordinator: coordinator)

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = appContainer
    window?.makeKeyAndVisible()
  }
}

private extension SceneDelegate {
  func configureLogServices() {
    let log = LogServiceComposer.shared
    log.register(service: OsLogService.shared)
  }
}
