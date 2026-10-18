//
//  CommitServicing.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation


import Foundation

// Separate service for the commits endpoint.
protocol CommitServicing {
    func fetchLatestCommit(user: String, repo: String) async throws -> Commit?
}

final class CommitService: CommitServicing {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    // The endpoint returns commits newest-first, so i just take the first one.
    func fetchLatestCommit(user: String, repo: String) async throws -> Commit? {
        guard let url = URL(string: "https://api.github.com/repos/\(user)/\(repo)/commits") else {
            throw NetworkError.invalidURL
        }
        let commits: [Commit] = try await client.request(url)
        return commits.first
    }
}
