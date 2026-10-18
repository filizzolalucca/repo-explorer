//
//  Repository.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

struct Repository: Decodable {
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let owner: Owner
    
    struct Owner: Decodable {
        let login: String
    }
}
