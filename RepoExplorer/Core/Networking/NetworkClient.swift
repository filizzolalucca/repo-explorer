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

        // GitHub uses snake_case and ISO 8601 dates, our models use camelCase and Date.
        // This spares us from writing CodingKeys and date parsing by hand.
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func request<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        // Treat anything outside 2xx as a failure, keeping the status code for the caller.
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, (200...299).contains(statusCode) else {
            throw NetworkError.invalidResponse(statusCode: statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Wrap the raw decoding error so callers get a typed one.
            throw NetworkError.decodingFailed(error)
        }
    }
}
