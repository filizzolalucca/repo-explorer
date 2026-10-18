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
    private let userService: UserServicing
    private let user: String

    init(repositoryService: RepositoryServicing = RepositoryService(),
         commitService: CommitServicing = CommitService(),
         userService: UserServicing = UserService(),
         user: String = GitHubConfig.username) {
        self.repositoryService = repositoryService
        self.commitService = commitService
        self.userService = userService
        self.user = user
    }

    // Shown above the list. Optional, so the list still works if it fails to load.
    private(set) var profile: UserProfile?

    // The source of truth for the table: one item per repo,
    // each carrying its own commit state.
    private(set) var items: [RepositoryCellViewModel] = []

    // Tracks which repos already had their commit requested,
    // so willDisplay doesn't fire the same call twice.
    private var commitRequested: Set<Int> = []

    // Keep the raw repos around to know owner/name for the commit call.
    private var repositories: [Repository] = []

    // Bumped on every reload, so responses from a previous load
    // (e.g. before a pull to refresh) are ignored instead of landing on the wrong row.
    private var loadGeneration = 0

    // MARK: - Table helpers

    var numberOfItems: Int { items.count }

    func item(at index: Int) -> RepositoryCellViewModel {
        items[index]
    }

    func repositoryURL(at index: Int) -> URL {
        repositories[index].htmlUrl
    }

    // MARK: - Data Loading

    /// Loads the profile and the repo list; commits are fetched later, per-cell, on demand.
    func loadRepositories() {
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading
        commitRequested.removeAll()
        items = []
        repositories = []
        Task { [weak self] in
            guard let self else { return }
            // Both requests run in parallel.
            async let profile = try? userService.fetchUser(user)
            do {
                let repos = try await repositoryService.fetchRepositories(for: user)
                let loadedProfile = await profile
                guard generation == self.loadGeneration else { return }
                self.profile = loadedProfile
                self.repositories = repos
                self.items = repos.map { repo in RepositoryCellViewModel(repository: repo) }
                self.state = .loaded
            } catch {
                guard generation == self.loadGeneration else { return }
                self.state = .error(error.localizedDescription)
            }
        }
    }

    /// Fetches a repo's latest commit on demand (called from willDisplay),
    /// so we only hit the API for cells the user actually sees.
    func loadCommitIfNeeded(at index: Int) {
        guard index < repositories.count, commitRequested.insert(index).inserted else { return }
        let repo = repositories[index]
        let generation = loadGeneration

        Task { [weak self] in
            guard let self else { return }
            let commitState: RepositoryCellViewModel.CommitState
            do {
                if let commit = try await self.commitService.fetchLatestCommit(
                    owner: repo.owner.login,
                    repo: repo.name
                ) {
                    commitState = .loaded(
                        sha: commit.sha,
                        message: commit.commit.message,
                        date: commit.commit.author.date
                    )
                } else {
                    commitState = .empty
                }
            } catch {
                commitState = .failed
            }
            guard generation == self.loadGeneration, index < self.items.count else { return }
            self.items[index].commitState = commitState
            // Always notify — success, empty or failure — so the cell leaves its shimmer.
            self.onCommitLoaded?(index)
        }
    }

    /// Requests a failed commit again, back in the loading state.
    func retryCommit(at index: Int) {
        guard index < items.count, items[index].isCommitFailed else { return }
        items[index].commitState = .loading
        commitRequested.remove(index)
        onCommitLoaded?(index)
        loadCommitIfNeeded(at: index)
    }
}
