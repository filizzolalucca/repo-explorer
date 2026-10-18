//
//  Commit.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 21/08/26.
//

import Foundation

struct Commit: Decodable {
    let sha: String
    let commit: CommitDetail

    struct CommitDetail: Decodable {
        let message: String
        let author: Author

        struct Author: Decodable {
            let name: String
            let date: String
        }
    }
}
