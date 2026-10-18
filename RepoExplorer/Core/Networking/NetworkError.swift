//
//  NetworkError.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

// Typed errors so the presentation layer can react properly
// instead of dealing with raw URLSession/decoding errors.
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int?)
    case decodingFailed(Error)

    // Shown to the user in the error alert.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request URL is invalid."
        case .invalidResponse(let statusCode) where statusCode == 403 || statusCode == 429:
            "GitHub's rate limit was reached. Please try again in a few minutes."
        case .invalidResponse:
            "GitHub returned an unexpected response. Please try again."
        case .decodingFailed:
            "Couldn't read the data returned by GitHub."
        }
    }
}
