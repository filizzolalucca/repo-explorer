//
//  NSAttributedString+Icon.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import UIKit

extension NSAttributedString {
    /// An SF Symbol followed by text, with the symbol sized to match the font.
    static func icon(
        _ symbolName: String,
        text: String,
        font: UIFont,
        iconColor: UIColor = .secondaryLabel,
        textColor: UIColor = .secondaryLabel
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let configuration = UIImage.SymbolConfiguration(font: font)
        if let image = UIImage(systemName: symbolName, withConfiguration: configuration)?
            .withTintColor(iconColor, renderingMode: .alwaysOriginal) {
            result.append(NSAttributedString(attachment: NSTextAttachment(image: image)))
            result.append(NSAttributedString(string: " "))
        }
        result.append(NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: textColor]))
        return result
    }
}
