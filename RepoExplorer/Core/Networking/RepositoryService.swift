//
//  RepositoryService.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

// I like to create one service per endpoint.
protocol RepositoryServicing {
    func fetchRepositories(for user: String) async throws -> [Repository]
}

final class RepositoryService: RepositoryServicing {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    // Most recently pushed first, so the latest work shows at the top.
    func fetchRepositories(for user: String) async throws -> [Repository] {
        guard let url = URL(string: "https://api.github.com/users/\(user)/repos?sort=pushed&per_page=100") else {
            throw NetworkError.invalidURL
        }
        return try await client.request(url)
    }
}
