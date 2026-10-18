//
//  ViewController.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Subviews
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
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
        view.backgroundColor = .white
        
        titleLabel.text = "Repository List"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        setupTableView()
        
        view.addSubviewContained(
            UIStackView(
                axis: .vertical,
                spacing: 24,
                arrangedSubviews: [
                    titleLabel,
                    tableView
                ]
            ),
            padding: 24,
            respectingSafeArea: true
        )
    }
    
    // MARK: Bind
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    self?.tableView.reloadData() // shows the 10 skeletons
                case .loaded:
                    self?.tableView.reloadData() // swaps skeletons for real cells
                case .error(let message):
                    self?.showErrorAlert(message: message)
                }
            }
        }
        viewModel.onCommitLoaded = { [weak self] index in
            DispatchQueue.main.async {
                // Reload just this row, not the whole table, so other cells don't flicker.
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseID)
        
        // Self-sizing cells: height adapts as the commit line swaps shimmer for text.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.state {
        case .loading: return 10
        case .loaded:  return viewModel.numberOfItems
        case .error:   return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RepositoryCell.reuseID,
            for: indexPath
        ) as! RepositoryCell
        
        switch viewModel.state {
        case .loading:
            cell.configure(with: .loadingRepository)
        case .loaded:
            cell.configure(with: viewModel.cellState(at: indexPath.row))
        case .error:
            break
        }
        return cell
    }
    
    // Task 2: fetch the commit only when the cell is about to appear.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Only fetch commits once the real list is shown (skeletons have no repo).
        guard case .loaded = viewModel.state else { return }
        viewModel.loadCommitIfNeeded(at: indexPath.row)
    }
}
