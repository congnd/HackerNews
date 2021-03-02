import UIKit
import Domain
import SnapKit

extension StoriesViewController {
  final class StoryCell: UITableViewCell {
    let sourceLabel = UILabel()
    let titleLabel = UILabel()
    let subtitleLabel1 = UILabel()
    let subtitleLabel2 = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupView()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setData(_ story: Story) {
      sourceLabel.text = story.url?.host?.uppercased()
      titleLabel.text = story.title
      subtitleLabel1.text = "by \(story.by)・\(story.time.elapsedTime)"
      subtitleLabel2.text = "\(story.score) points・\(story.descendants ?? 0) comments"
    }
  }
}

private extension StoriesViewController.StoryCell {
  func setupView() {
    backgroundColor = .clear
    selectionStyle = .none

    let container = UIView()
    contentView.addSubview(container)
    container.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview().inset(12)
    }

    titleLabel.numberOfLines = 0
    titleLabel.textColor = .black
    titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

    sourceLabel.textColor = .lightGray
    sourceLabel.font = .systemFont(ofSize: 12)

    subtitleLabel1.textColor = .lightGray
    subtitleLabel1.font = .systemFont(ofSize: 14)

    subtitleLabel2.textColor = .lightGray
    subtitleLabel2.font = .systemFont(ofSize: 14)

    let subviews = [sourceLabel, titleLabel, subtitleLabel1, subtitleLabel2]
    let vStack = VStack(spacing: 6, distribution: .fill, aligment: .trailing, subviews: subviews)
    container.addSubview(vStack)
    vStack.snp.makeConstraints { $0.edges.equalToSuperview() }

    let separator = UIView()
    separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
    addSubview(separator)
    separator.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
