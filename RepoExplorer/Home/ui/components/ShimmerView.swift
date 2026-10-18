//
//  ShimmerView.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import UIKit

// Animated skeleton placeholder with a left-to-right shimmer sweep.
// Reusable wherever content is still loading. Pill-shaped by default.
final class ShimmerView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .systemGray5
        clipsToBounds = true

        updateColors()
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5) // horizontal
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    // CGColors don't follow light/dark mode on their own, so resolve them again on change.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }

    private func updateColors() {
        // base -> highlight -> base, so the light band sweeps across.
        let base = UIColor.systemGray5.resolvedColor(with: traitCollection).cgColor
        let highlight = UIColor.systemGray6.resolvedColor(with: traitCollection).cgColor
        gradientLayer.colors = [base, highlight, base]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds // layers ignore Auto Layout
        layer.cornerRadius = bounds.height / 2 // always a pill
    }
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0] // highlight enters from the left
        animation.toValue = [1.0, 1.5, 2.0]  // and exits right
        animation.duration = 1.2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}

extension ShimmerView {
    /// Creates a shimmer with a fixed size, already Auto Layout-ready.
    convenience init(width: CGFloat, height: CGFloat) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
