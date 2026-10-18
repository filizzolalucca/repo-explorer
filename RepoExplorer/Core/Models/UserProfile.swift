//
//  UserProfile.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import Foundation

struct UserProfile: Decodable {
    let login: String
    let name: String?
    let bio: String?
    let avatarUrl: URL
    let publicRepos: Int
    let followers: Int
}
