//
//  UILabel+Layout.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import Foundation

import UIKit

extension UILabel {
    /// Convenience init to configure a label in one call.
    convenience init(
        font: UIFont,
        text: String? = nil,
        textColor: UIColor = .label,
        numberOfLines: Int = 0
    ) {
        self.init()
        self.font = font
        self.text = text
        self.textColor = textColor
        self.numberOfLines = numberOfLines
    }
}
