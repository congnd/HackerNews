import UIKit
import RxSwift
import RxCocoa
import SnapKit

public protocol StoriesCoordinating: Coordinator {
  func openUrl(_ url: URL)
}

public class StoriesViewController: UIViewController {
  private weak var coordinator: StoriesCoordinating!
  private let viewModel: StoriesViewModel

  private let tableView = UITableView()

  private lazy var sortButton: UIBarButtonItem = {
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .default)
    return UIBarButtonItem(
      image: UIImage(systemName: "arrow.up.arrow.down", withConfiguration: config),
      style: .plain,
      target: self,
      action: #selector(showSortOptions))
  }()

  private let sort = PublishRelay<StoriesViewModel.Input.SortBy>()

  private let disposeBag = DisposeBag()

  public init(coordinator: StoriesCoordinating, viewModel: StoriesViewModel) {
    self.coordinator = coordinator
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    super.loadView()
    setupView()
    setupBinding()
  }
}

private extension StoriesViewController {
  func setupView() {
    title = "Stories"
    navigationController?.navigationBar.isHidden = false

    tableView.backgroundColor = .clear
    tableView.separatorColor = .clear
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 150
    tableView.refreshControl = UIRefreshControl()
    tableView.register(StoryCell.self)

    view.addSubview(tableView)
    tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

    navigationItem.rightBarButtonItem = sortButton
  }

  @objc func showSortOptions() {
    let sheet = UIAlertController(
      title: "Sort stories by",
      message: nil,
      preferredStyle: .actionSheet)
    sheet.addAction(UIAlertAction(title: "Time", style: .default, handler: { _ in
      self.sort.accept(.time)
    }))
    sheet.addAction(UIAlertAction(title: "Score", style: .default, handler: { _ in
      self.sort.accept(.score)
    }))
    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    if let popoverController = sheet.popoverPresentationController {
      popoverController.barButtonItem = sortButton
    }
    present(sheet, animated: true)
  }

  func setupBinding() {
    let refresh = tableView.refreshControl!.rx.controlEvent(.valueChanged)
      .filter { self.tableView.refreshControl!.isRefreshing }

    let input = StoriesViewModel.Input(viewDidLoad: rx.viewDidLoad, refresh: refresh, sort: sort)
    let output = viewModel.transform(input)

    output.reloadTableView.emit(to: reloadTableView).disposed(by: disposeBag)
    output.changes.emit(to: updateTableView).disposed(by: disposeBag)
    output.embeddedIndicator.emit(to: rx.showEmbeddedActivityIndicator).disposed(by: disposeBag)
    output.embeddedError.emit(to: rx.showEmbeddedMessage).disposed(by: disposeBag)
    output.floatingError.emit(to: rx.showAlert).disposed(by: disposeBag)
    output.isRefreshing.emit(to: tableView.refreshControl!.rx.isRefreshing).disposed(by: disposeBag)
    output.isSortAllowed.drive(sortButton.rx.isEnabled).disposed(by: disposeBag)
  }
}

extension StoriesViewController: UITableViewDataSource, UITableViewDelegate {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.rows.count
  }

  public func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let story = viewModel.rows[indexPath.row]

    let cell = tableView.dequeueReusableCell(StoryCell.self, for: indexPath)
    cell.setData(story)

    return cell
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let url = viewModel.rows[indexPath.row].url else { return }
    coordinator.openUrl(url)
  }
}

extension StoriesViewController {
  var reloadTableView: Binder<Void> {
    .init(self) { base, _ in
      base.tableView.reloadData()
    }
  }

  var updateTableView: Binder<(added: [IndexPath], removed: [IndexPath], updated: [IndexPath])> {
    .init(self) { base, changes in
      UIView.performWithoutAnimation {
        base.tableView.performBatchUpdates({
          base.tableView.deleteRows(at: changes.removed, with: .none)
          base.tableView.insertRows(at: changes.added, with: .none)
        })
        base.tableView.reloadRows(at: changes.updated, with: .none)
      }
    }
  }
}
