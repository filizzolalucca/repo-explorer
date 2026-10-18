//
//  NetworkClient.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

// Small transport layer. Every service goes through this so the
// URLSession + decoding setup lives in one place only.
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ url: URL) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        // GitHub uses snake_case, our models use camelCase.
        // This spares us from writing CodingKeys by hand.
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func request<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        // Treat anything outside 2xx as a failure.
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Wrap the raw decoding error so callers get a typed one.
            throw NetworkError.decodingFailed(error)
        }
    }
}
