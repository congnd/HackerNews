import UIKit

final class HStack: UIStackView {
  init(
    spacing: CGFloat = 0,
    distribution: UIStackView.Distribution = .fill,
    aligment: UIStackView.Alignment = .center,
    subviews: [UIView]
  ) {
    super.init(frame: .zero)
    self.axis = .horizontal
    self.spacing = spacing
    self.distribution = distribution
    self.alignment = alignment
    self.addArrangedSubviews(subviews)
  }

  func addArrangedSubviews(_ subviews: [UIView]) {
    subviews.forEach { self.addArrangedSubview($0) }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class VStack: UIStackView {
  init(
    spacing: CGFloat = 0,
    distribution: UIStackView.Distribution = .fill,
    aligment: UIStackView.Alignment = .center,
    subviews: [UIView] = []
  ) {
    super.init(frame: .zero)
    self.axis = .vertical
    self.spacing = spacing
    self.distribution = distribution
    self.alignment = alignment
    self.addArrangedSubviews(subviews)
  }

  func addArrangedSubviews(_ subviews: [UIView]) {
    subviews.forEach { self.addArrangedSubview($0) }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
