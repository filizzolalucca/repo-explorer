//
//  RepositoryCell.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import Foundation
import UIKit


/// Presentation state for the cell: whole-card skeleton, or loaded content.
enum RepositoryCellState {
    case loadingRepository
    case loaded(RepositoryCellViewModel)
}

final class RepositoryCell: UITableViewCell {
    static let reuseID = "RepositoryCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    private let nameLabel = UILabel(
        font: .systemFont(ofSize: 20, weight: .bold)
    )
    
    private let descriptionLabel = UILabel(
        font: .systemFont(ofSize: 15),
        textColor: .secondaryLabel,
        numberOfLines: 0
    )
    
    private let commitLabel = UILabel(
        font: .systemFont(ofSize: 15)
    )
    
    private let commitShimmer = ShimmerView(width: 140, height: 16)
    
    private let starsLabel = UILabel(
        font: .systemFont(ofSize: 13),
        textColor: .secondaryLabel
    )
    private let forksLabel = UILabel(
        font: .systemFont(ofSize: 13),
        textColor: .secondaryLabel
    )
    private let languageLabel = UILabel(
        font: .systemFont(ofSize: 13),
        textColor: .secondaryLabel
    )
    
    // MARK: - Skeleton views (whole-card loading)
    
    private let nameShimmer = ShimmerView(width: 200, height: 22)
    private let descShimmer = ShimmerView(width: 260, height: 16)
    private let commitSkeletonShimmer = ShimmerView(width: 140, height: 16)
    private let footerShimmer = ShimmerView(width: 180, height: 14)
    
    // MARK: - Stacks (all the arrangement lives here)
    
    private lazy var commitStack = UIStackView(
        axis: .vertical,
        spacing: .init(8),
        alignment: .leading,
        arrangedSubviews: [
            commitLabel,
            commitShimmer
        ]
    )
    
    private lazy var footerStack = UIStackView(
        axis: .horizontal,
        spacing: 16,
        distribution: .fillProportionally,
        arrangedSubviews: [starsLabel, forksLabel, languageLabel]
    )
    
    private lazy var mainStack = UIStackView(
        axis: .vertical,
        spacing: 8,
        arrangedSubviews: [nameLabel, descriptionLabel, commitStack, footerStack]
    )
    
    // MARK: - Stacks (skeleton)
    
    private lazy var skeletonStack = UIStackView(
        axis: .vertical,
        spacing: 8,
        arrangedSubviews: [nameShimmer, descShimmer, commitSkeletonShimmer, footerShimmer]
    )
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubviewContained(cardView, padding: 8)
    }
    
    // Swaps skeleton and content stacks in/out rather than overlaying them,
    // so the fixed-width shimmers never constrain the multiline labels
    func configure(with state: RepositoryCellState) {
        mainStack.removeFromSuperview()
        skeletonStack.removeFromSuperview()
        
        switch state {
        case .loadingRepository:
            cardView.addSubviewContained(skeletonStack, padding: 16)
            showSkeleton(true)
        case .loaded(let viewModel):
            cardView.addSubviewContained(mainStack, padding: 16)
            showSkeleton(false)
            fillContent(with: viewModel)
        }
    }
    
    private func showSkeleton(_ show: Bool) {
        skeletonStack.isHidden = !show
        mainStack.isHidden = show
        
        let bars = [nameShimmer, descShimmer, commitSkeletonShimmer, footerShimmer]
        if show {
            bars.forEach { $0.startAnimating() }
        } else {
            bars.forEach { $0.stopAnimating() }
        }
    }
    
    private func fillContent(with viewModel: RepositoryCellViewModel) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        starsLabel.text = viewModel.stars
        forksLabel.text = viewModel.forks
        languageLabel.text = viewModel.language
        
        switch viewModel.commitState {
          case .loading:
              commitLabel.isHidden = true
              commitShimmer.isHidden = false
              commitShimmer.startAnimating()
          case .loaded(let sha):
              showCommitText("Last commit: \(sha.prefix(7))")
          case .empty:
              showCommitText("No commits in this repository")
          case .failed:
              showCommitText("Failed to load commit")
          }

    }
    
    private func showCommitText(_ text: String) {
        commitShimmer.stopAnimating()
        commitShimmer.isHidden = true
        commitLabel.isHidden = false
        commitLabel.text = text
    }
    
    
    // MARK: - Reuse
    
    // Reset animations and text so a recycled cell never shows stale content.
    override func prepareForReuse() {
        super.prepareForReuse()
        [commitShimmer, nameShimmer, descShimmer, commitSkeletonShimmer, footerShimmer]
            .forEach { $0.stopAnimating() }
        nameLabel.text = nil
        descriptionLabel.text = nil
        commitLabel.text = nil
    }
}
