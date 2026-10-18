//
//  CommitService.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

// Separate service for the commits endpoint.
protocol CommitServicing {
    func fetchLatestCommit(owner: String, repo: String) async throws -> Commit?
}

final class CommitService: CommitServicing {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    // The endpoint returns commits newest-first, so asking for a single one is enough.
    func fetchLatestCommit(owner: String, repo: String) async throws -> Commit? {
        guard let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=1") else {
            throw NetworkError.invalidURL
        }
        do {
            let commits: [Commit] = try await client.request(url)
            return commits.first
        } catch NetworkError.invalidResponse(statusCode: 409?) {
            // GitHub answers 409 Conflict for repositories with no commits.
            return nil
        }
    }
}
