//
//  HomeViewModel.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import Foundation

final class HomeViewModel {
    
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
    
    // Emits to the view whenever the state changes (lightweight observable).
    private(set) var state: ViewState = .loading {
        didSet { onStateChange?(state) }
    }
    
    var onStateChange: ((ViewState) -> Void)?
    
    // Called when a single cell's commit finishes loading,
    // so the view can reload just that row.
    var onCommitLoaded: ((Int) -> Void)?
    
    
    // MARK: - Init
    
    private let repositoryService: RepositoryServicing
    private let commitService: CommitServicing
    private let user: String
    
    init(repositoryService: RepositoryServicing = RepositoryService(),
         commitService: CommitServicing = CommitService(),
         user: String = "mralexgray") {
        self.repositoryService = repositoryService
        self.commitService = commitService
        self.user = user
    }
    
    // The source of truth for the table: one item per repo,
    // each carrying its own commit state.
    private(set) var items: [RepositoryCellViewModel] = []
    
    // Tracks which repos already had their commit requested,
    // so willDisplay doesn't fire the same call twice.
    private var commitRequested: Set<Int> = []
    
    // Keep the raw repos around to know owner/name for the commit call.
    private var repositories: [Repository] = []
    
    // MARK: - Table helpers
    
    var numberOfItems: Int { items.count }
    
    func item(at index: Int) -> RepositoryCellViewModel {
        items[index]
    }
    
    func cellState(at index: Int) -> RepositoryCellState {
        .loaded(items[index])
    }
    
    // MARK: - Data Loading
    
    /// Loads the repo list; commits are fetched later, per-cell, on demand.
    func loadRepositories() {
        state = .loading
        commitRequested.removeAll()
        items = []
        repositories = []
        Task { [weak self] in
            guard let self else { return }
            do {
                let repos = try await repositoryService.fetchRepositories(for: user)
                self.repositories = repos
                self.items = repos.map { repo in RepositoryCellViewModel(repository: repo) }
                self.state = .loaded
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }
    
    /// Fetches a repo's latest commit on demand (called from willDisplay),
    /// so we only hit the API for cells the user actually sees.

    func loadCommitIfNeeded(at index: Int) {
        guard commitRequested.insert(index).inserted else { return }
        
        Task { [weak self] in
            guard let self else { return }
            guard index < self.items.count else { return }
            let repo = self.repositories[index]
            do {
                let commit = try await self.commitService.fetchLatestCommit(
                    user: self.user,
                    repo: repo.name
                )
                if let commit {
                    self.items[index].commitState = .loaded(commit.sha)
                } else {
                    self.items[index].commitState = .empty
                }
            } catch {
                self.items[index].commitState = .failed
            }
            // Always notify — success, empty or failure — so the cell leaves its shimmer.
            self.onCommitLoaded?(index)
        }
        
    }
}
