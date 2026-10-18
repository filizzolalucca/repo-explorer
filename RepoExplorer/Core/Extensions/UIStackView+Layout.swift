//
//  UIStackView+Layout.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import UIKit

extension UIStackView {
    /// Convenience init to configure a stack in one call.
    convenience init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 0,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        arrangedSubviews: [UIView] = []
    ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
    }
}
