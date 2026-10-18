//
//  UserService.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import Foundation

// Profile shown at the top of the list.
protocol UserServicing {
    func fetchUser(_ login: String) async throws -> UserProfile
}

final class UserService: UserServicing {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    func fetchUser(_ login: String) async throws -> UserProfile {
        guard let url = URL(string: "https://api.github.com/users/\(login)") else {
            throw NetworkError.invalidURL
        }
        return try await client.request(url)
    }
}
