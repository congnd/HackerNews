import UIKit
import RxSwift
import RxCocoa
import SnapKit

public protocol StoriesCoordinating: Coordinator {}

public class StoriesViewController: UIViewController {
  private weak var coordinator: StoriesCoordinating!
  private let viewModel: StoriesViewModel

  private let tableView = UITableView()

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
    tableView.estimatedRowHeight = 400
    tableView.refreshControl = UIRefreshControl()
    tableView.register(StoryCell.self)

    view.addSubview(tableView)
    tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }

  func setupBinding() {
    let input = StoriesViewModel.Input()
    let output = viewModel.transform(input)
    
    output.reloadTableView.emit(to: reloadTableView).disposed(by: disposeBag)
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
