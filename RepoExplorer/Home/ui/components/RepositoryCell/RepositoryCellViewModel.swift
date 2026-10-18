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
    let language: String
    var commitState: CommitState
    
    enum CommitState {
        case loading
        case loaded(String)
        case empty
        case failed
    }
    
    init(repository: Repository, commitState: CommitState = .loading) {
        self.name = repository.name
        self.description = repository.description ?? "No description"
        self.stars = "Stars: \(repository.stargazersCount)"
        self.forks = "Forks: \(repository.forksCount)"
        self.language = "Language: \(repository.language ?? "N/A")"
        self.commitState = commitState
    }
}
