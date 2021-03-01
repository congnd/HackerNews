import UIKit

public protocol Coordinator: class {
  var navigationController: UINavigationController { get }
  var childCoordinators: [Coordinator] { get set }

  /// The root view controller for the coordinator.
  /// This view controller sometimes can be different
  /// from the root view controller of the navigationController
  var rootViewController: UIViewController? { get set }

  func start()
}
