import UIKit
import RxSwift
import RxCocoa
import SnapKit

private let embeddedActivityIndicatorTag = UUID().hashValue
private let embeddedMessageTag = UUID().hashValue

// MARK: - UIViewController
public extension Reactive where Base: UIViewController {
  /// Reactive wrapper when view did load is fired
  var viewDidLoad: ControlEvent<Void> {
    return ControlEvent(events: self.sentMessage(#selector(Base.viewDidLoad)).map { _ in Void() })
  }

  var showEmbeddedActivityIndicator: Binder<Bool> {
    return Binder(self.base) { base, shouldShow in
      if shouldShow {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.tag = embeddedActivityIndicatorTag
        base.view.insertSubview(indicator, at: 0)
        indicator.snp.makeConstraints { $0.center.equalToSuperview() }
        indicator.startAnimating()
      } else {
        let indicator = base.view.subviews.first {
          $0 is UIActivityIndicatorView && $0.tag == embeddedActivityIndicatorTag
        }
        indicator?.removeFromSuperview()
      }
    }
  }

  var showEmbeddedMessage: Binder<String?> {
    return Binder(self.base) { base, message in
      if let message = message {
        let label = UILabel()
        label.tag = embeddedMessageTag
        label.text = message
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .center

        base.view.insertSubview(label, at: 0)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
      } else {
        let label = base.view.subviews.first {
          $0 is UILabel && $0.tag == embeddedMessageTag
        }
        label?.removeFromSuperview()
      }
    }
  }

  var showAlert: Binder<String> {
    return Binder(base) { _, message in
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      base.present(alert, animated: true)
    }
  }
}
