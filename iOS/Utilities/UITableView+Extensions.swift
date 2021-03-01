import UIKit

protocol RegistrableCell {
  static var identifier: String { get }
}

extension RegistrableCell {
  static var identifier: String {
    String(describing: Self.self)
  }
}

extension UITableViewCell: RegistrableCell {}

extension UITableView {
  func register<T: UITableViewCell>(_ cellClass: T.Type) {
    register(cellClass, forCellReuseIdentifier: cellClass.identifier)
  }

  // swiftlint:disable force_cast
  func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath) as! T
  }
}
