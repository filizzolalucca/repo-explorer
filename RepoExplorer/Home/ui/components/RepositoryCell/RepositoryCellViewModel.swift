//
//  RepositoryCellViewModel.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import Foundation

/// Display-ready contract for a repository cell.
/// All formatting and optional-handling happens here, not in the view.
struct RepositoryCellViewModel {
    let name: String
    let description: String
    let stars: String
    let forks: String
    let language: String?
    var commitState: CommitState

    enum CommitState {
        case loading
        case loaded(sha: String, message: String, date: Date)
        case empty
        case failed
    }

    init(repository: Repository, commitState: CommitState = .loading) {
        self.name = repository.name
        self.description = repository.description ?? "No description"
        self.stars = repository.stargazersCount.formatted()
        self.forks = repository.forksCount.formatted()
        self.language = repository.language
        self.commitState = commitState
    }

    // MARK: - Commit line

    /// Short SHA, like GitHub shows it.
    var commitSHA: String? {
        guard case .loaded(let sha, _, _) = commitState else { return nil }
        return String(sha.prefix(7))
    }

    var commitText: String {
        switch commitState {
        case .loading:
            ""
        case .loaded(_, let message, _):
            // Only the subject line, the body usually adds noise in a list.
            message.components(separatedBy: .newlines).first ?? message
        case .empty:
            "No commits yet"
        case .failed:
            "Couldn't load the last commit. Tap to retry."
        }
    }

    var commitDate: String? {
        guard case .loaded(_, _, let date) = commitState else { return nil }
        return "Committed \(Self.relativeFormatter.localizedString(for: date, relativeTo: .now))"
    }

    var isCommitFailed: Bool {
        if case .failed = commitState { return true }
        return false
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}
