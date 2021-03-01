import UIKit
import SnapKit

public final class AppContainerController: UIViewController {
  let coordinator: Coordinator

  public init(coordinator: Coordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    super.loadView()
    view.backgroundColor = .white

    addChild(coordinator.navigationController)
    view.addSubview(coordinator.navigationController.view)
    coordinator.navigationController.didMove(toParent: self)

    coordinator.start()
  }
}
