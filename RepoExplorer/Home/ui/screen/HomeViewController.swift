//
//  HomeViewController.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import SafariServices
import UIKit

final class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private enum Section: Int, CaseIterable {
        case profile
        case repositories
    }

    // MARK: Subviews

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    // MARK: Injected properties

    let viewModel: HomeViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configure()
        viewModel.loadRepositories()
    }

    // MARK: Configuration

    private func configure() {
        title = "Repositories"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        setupTableView()
        view.addSubviewContained(tableView)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.reuseID)
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseID)

        // Self-sizing cells: height adapts as the commit line swaps shimmer for text.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refresh() {
        viewModel.loadRepositories()
    }

    // MARK: Bind

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self else { return }
                switch state {
                case .loading:
                    self.tableView.reloadData() // shows the skeletons
                case .loaded:
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData() // swaps skeletons for real cells
                case .error(let message):
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.showErrorAlert(message: message)
                }
            }
        }
        viewModel.onCommitLoaded = { [weak self] index in
            DispatchQueue.main.async {
                guard let self, index < self.viewModel.numberOfItems else { return }
                // Fade just this row, so the commit doesn't pop in and other cells don't flicker.
                let indexPath = IndexPath(row: index, section: Section.repositories.rawValue)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.viewModel.loadRepositories()
        })
        present(alert, animated: true)
    }

    // MARK: Table view

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch (section, viewModel.state) {
        case (.profile, .loading): return 1
        case (.profile, .loaded): return viewModel.profile == nil ? 0 : 1
        case (.repositories, .loading): return 8
        case (.repositories, .loaded): return viewModel.numberOfItems
        case (_, .error): return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.profile.rawValue {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileCell.reuseID,
                for: indexPath
            ) as! ProfileCell
            cell.configure(with: viewModel.profile)
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: RepositoryCell.reuseID,
            for: indexPath
        ) as! RepositoryCell

        if case .loaded = viewModel.state {
            cell.configure(with: .loaded(viewModel.item(at: indexPath.row)))
        } else {
            cell.configure(with: .loadingRepository)
        }
        return cell
    }

    // Fetch the commit only when the cell is about to appear.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Only fetch commits once the real list is shown (skeletons have no repo).
        guard indexPath.section == Section.repositories.rawValue,
              case .loaded = viewModel.state else { return }
        viewModel.loadCommitIfNeeded(at: indexPath.row)
    }

    // Tapping a card retries its commit if it failed, otherwise opens the repository on GitHub.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == Section.repositories.rawValue,
              case .loaded = viewModel.state else { return }

        if viewModel.item(at: indexPath.row).isCommitFailed {
            viewModel.retryCommit(at: indexPath.row)
        } else {
            present(SFSafariViewController(url: viewModel.repositoryURL(at: indexPath.row)), animated: true)
        }
    }
}
