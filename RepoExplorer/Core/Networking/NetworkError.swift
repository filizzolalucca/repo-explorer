//
//  NetworkError.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

// Typed errors so the presentation layer can react properly
// instead of dealing with raw URLSession/decoding errors.
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
}
