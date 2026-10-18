//
//  UIColor+Language.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import UIKit

extension UIColor {
    /// The color GitHub uses for a programming language, or gray when it's unknown.
    static func language(_ name: String?) -> UIColor {
        switch name {
        case "Swift": UIColor(hex: 0xF05138)
        case "Kotlin": UIColor(hex: 0xA97BFF)
        case "Dart": UIColor(hex: 0x00B4AB)
        case "Java": UIColor(hex: 0xB07219)
        case "TypeScript": UIColor(hex: 0x3178C6)
        case "JavaScript": UIColor(hex: 0xF1E05A)
        case "Python": UIColor(hex: 0x3572A5)
        case "Go": UIColor(hex: 0x00ADD8)
        case "C++": UIColor(hex: 0xF34B7D)
        case "HTML": UIColor(hex: 0xE34C26)
        case "CSS": UIColor(hex: 0x563D7C)
        default: .systemGray
        }
    }

    private convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
