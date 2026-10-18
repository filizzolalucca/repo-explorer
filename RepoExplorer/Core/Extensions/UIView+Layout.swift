//
//  UIView+Layout.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import UIKit

extension UIView {
    /// Pins a subview to the parent's edges (or its safe area) with optional padding.
    func addSubviewContained(
        _ subview: UIView,
        padding: CGFloat = 0,
        respectingSafeArea: Bool = false
    ) {
        addSubviewContained(
            subview,
            insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding),
            respectingSafeArea: respectingSafeArea
        )
    }

    /// Same as above, with a different inset per edge.
    func addSubviewContained(
        _ subview: UIView,
        insets: UIEdgeInsets,
        respectingSafeArea: Bool = false
    ) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        
        let top: NSLayoutYAxisAnchor
        let bottom: NSLayoutYAxisAnchor
        let leading: NSLayoutXAxisAnchor
        let trailing: NSLayoutXAxisAnchor
        
        if respectingSafeArea {
            let guide = safeAreaLayoutGuide
            top = guide.topAnchor
            bottom = guide.bottomAnchor
            leading = guide.leadingAnchor
            trailing = guide.trailingAnchor
        } else {
            top = topAnchor
            bottom = bottomAnchor
            leading = leadingAnchor
            trailing = trailingAnchor
        }
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: top, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottom, constant: -insets.bottom),
            subview.leadingAnchor.constraint(equalTo: leading, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailing, constant: -insets.right)
        ])
    }
}
