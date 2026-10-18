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
            subview.topAnchor.constraint(equalTo: top, constant: padding),
            subview.bottomAnchor.constraint(equalTo: bottom, constant: -padding),
            subview.leadingAnchor.constraint(equalTo: leading, constant: padding),
            subview.trailingAnchor.constraint(equalTo: trailing, constant: -padding)
        ])
    }
}
