//
//  RepositoryCell.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 22/08/26.
//

import UIKit


/// Presentation state for the cell: whole-card skeleton, or loaded content.
enum RepositoryCellState {
    case loadingRepository
    case loaded(RepositoryCellViewModel)
}

final class RepositoryCell: UITableViewCell {
    static let reuseID = "RepositoryCell"

    private static let footerFont = UIFont.systemFont(ofSize: 13)

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        return view
    }()

    private let nameLabel = UILabel(
        font: .systemFont(ofSize: 18, weight: .bold)
    )

    private let descriptionLabel = UILabel(
        font: .systemFont(ofSize: 15),
        textColor: .secondaryLabel,
        numberOfLines: 0
    )

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()

    private let commitLabel = UILabel(
        font: .systemFont(ofSize: 14),
        numberOfLines: 2
    )

    private let commitDateLabel = UILabel(
        font: .systemFont(ofSize: 12),
        textColor: .tertiaryLabel
    )

    private let commitShimmer = ShimmerView(width: 180, height: 16)

    private let starsLabel = UILabel(font: RepositoryCell.footerFont)
    private let forksLabel = UILabel(font: RepositoryCell.footerFont)
    private let languageLabel = UILabel(font: RepositoryCell.footerFont)

    // MARK: - Skeleton views (whole-card loading)

    private let nameShimmer = ShimmerView(width: 200, height: 22)
    private let descShimmer = ShimmerView(width: 260, height: 16)
    private let commitSkeletonShimmer = ShimmerView(width: 180, height: 16)
    private let footerShimmer = ShimmerView(width: 140, height: 14)

    // MARK: - Stacks (all the arrangement lives here)

    private lazy var commitStack = UIStackView(
        axis: .vertical,
        spacing: 4,
        alignment: .leading,
        arrangedSubviews: [
            commitLabel,
            commitDateLabel,
            commitShimmer
        ]
    )

    // The trailing spacer keeps the footer items packed to the left.
    private lazy var footerStack = UIStackView(
        axis: .horizontal,
        spacing: 16,
        alignment: .center,
        arrangedSubviews: [starsLabel, forksLabel, languageLabel, UIView()]
    )

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(
            axis: .vertical,
            spacing: 8,
            arrangedSubviews: [nameLabel, descriptionLabel, separatorView, commitStack, footerStack]
        )
        stack.setCustomSpacing(12, after: descriptionLabel)
        stack.setCustomSpacing(12, after: separatorView)
        stack.setCustomSpacing(12, after: commitStack)
        return stack
    }()

    // MARK: - Stacks (skeleton)

    private lazy var skeletonStack = UIStackView(
        axis: .vertical,
        spacing: 10,
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
        updateBorderColor()

        contentView.addSubviewContained(
            cardView,
            insets: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        )
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
        starsLabel.attributedText = .icon("star", text: viewModel.stars, font: Self.footerFont)
        forksLabel.attributedText = .icon("arrow.triangle.branch", text: viewModel.forks, font: Self.footerFont)
        languageLabel.attributedText = .icon(
            "circle.fill",
            text: viewModel.language ?? "",
            font: Self.footerFont,
            iconColor: .language(viewModel.language)
        )
        languageLabel.isHidden = viewModel.language == nil

        switch viewModel.commitState {
        case .loading:
            commitLabel.isHidden = true
            commitDateLabel.isHidden = true
            commitShimmer.isHidden = false
            commitShimmer.startAnimating()
        case .loaded, .empty, .failed:
            showCommit(for: viewModel)
        }
    }

    private func showCommit(for viewModel: RepositoryCellViewModel) {
        commitShimmer.stopAnimating()
        commitShimmer.isHidden = true
        commitLabel.isHidden = false
        commitLabel.attributedText = commitText(for: viewModel)
        commitDateLabel.text = viewModel.commitDate
        commitDateLabel.isHidden = viewModel.commitDate == nil
    }

    // Monospaced SHA followed by the commit subject, like GitHub's commit list.
    private func commitText(for viewModel: RepositoryCellViewModel) -> NSAttributedString {
        let text = NSMutableAttributedString()
        if let sha = viewModel.commitSHA {
            text.append(NSAttributedString(string: sha + "  ", attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.systemBlue
            ]))
        }
        text.append(NSAttributedString(string: viewModel.commitText, attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: viewModel.isCommitFailed ? UIColor.systemRed : UIColor.label
        ]))
        return text
    }

    // MARK: - Appearance

    // Small press feedback, since tapping a card opens the repository.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }

    // Layer colors don't adapt to dark mode by themselves.
    private func updateBorderColor() {
        cardView.layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
    }

    // MARK: - Reuse

    // Reset animations and text so a recycled cell never shows stale content.
    override func prepareForReuse() {
        super.prepareForReuse()
        [commitShimmer, nameShimmer, descShimmer, commitSkeletonShimmer, footerShimmer]
            .forEach { $0.stopAnimating() }
        nameLabel.text = nil
        descriptionLabel.text = nil
        commitLabel.attributedText = nil
        commitDateLabel.text = nil
    }
}
