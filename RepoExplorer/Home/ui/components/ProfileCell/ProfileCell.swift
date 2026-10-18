//
//  ProfileCell.swift
//  RepoExplorer
//
//  Created by Lucca Filizzola on 18/10/26.
//

import UIKit

/// Header row with the account's avatar, name, bio and counts.
/// Shows a skeleton while the profile is loading.
final class ProfileCell: UITableViewCell {
    static let reuseID = "ProfileCell"

    private static let avatarSize: CGFloat = 72
    private static let statsFont = UIFont.systemFont(ofSize: 13)

    private let avatarView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = ProfileCell.avatarSize / 2
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: ProfileCell.avatarSize),
            view.heightAnchor.constraint(equalToConstant: ProfileCell.avatarSize)
        ])
        return view
    }()

    private let nameLabel = UILabel(font: .systemFont(ofSize: 22, weight: .bold))
    private let loginLabel = UILabel(font: .systemFont(ofSize: 15), textColor: .secondaryLabel)
    private let bioLabel = UILabel(font: .systemFont(ofSize: 15))
    private let statsLabel = UILabel(font: ProfileCell.statsFont)

    // MARK: - Skeleton views

    private let avatarShimmer = ShimmerView(width: ProfileCell.avatarSize, height: ProfileCell.avatarSize)
    private let nameShimmer = ShimmerView(width: 160, height: 22)
    private let loginShimmer = ShimmerView(width: 110, height: 14)

    // MARK: - Stacks

    private lazy var contentStack = UIStackView(
        axis: .vertical,
        spacing: 12,
        arrangedSubviews: [
            UIStackView(
                axis: .horizontal,
                spacing: 16,
                alignment: .center,
                arrangedSubviews: [
                    avatarView,
                    UIStackView(axis: .vertical, spacing: 2, arrangedSubviews: [nameLabel, loginLabel])
                ]
            ),
            bioLabel,
            statsLabel
        ]
    )

    private lazy var skeletonStack = UIStackView(
        axis: .horizontal,
        spacing: 16,
        alignment: .center,
        arrangedSubviews: [
            avatarShimmer,
            UIStackView(axis: .vertical, spacing: 10, alignment: .leading, arrangedSubviews: [nameShimmer, loginShimmer])
        ]
    )

    // The avatar being shown, so a reload with the same profile doesn't flash it.
    private var avatarURL: URL?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Pass `nil` while loading to show the skeleton.
    func configure(with profile: UserProfile?) {
        contentStack.removeFromSuperview()
        skeletonStack.removeFromSuperview()
        let shimmers = [avatarShimmer, nameShimmer, loginShimmer]
        let insets = UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20)

        guard let profile else {
            contentView.addSubviewContained(skeletonStack, insets: insets)
            shimmers.forEach { $0.startAnimating() }
            return
        }

        shimmers.forEach { $0.stopAnimating() }
        contentView.addSubviewContained(contentStack, insets: insets)
        nameLabel.text = profile.name ?? profile.login
        loginLabel.text = "@\(profile.login)"
        bioLabel.text = profile.bio
        bioLabel.isHidden = profile.bio?.isEmpty ?? true
        statsLabel.attributedText = stats(for: profile)
        loadAvatar(from: profile.avatarUrl)
    }

    private func stats(for profile: UserProfile) -> NSAttributedString {
        let repos = profile.publicRepos == 1 ? "1 repository" : "\(profile.publicRepos) repositories"
        let followers = profile.followers == 1 ? "1 follower" : "\(profile.followers) followers"
        let text = NSMutableAttributedString()
        text.append(.icon("book.closed", text: repos, font: Self.statsFont))
        text.append(NSAttributedString(string: "     "))
        text.append(.icon("person.2", text: followers, font: Self.statsFont))
        return text
    }

    private func loadAvatar(from url: URL) {
        guard avatarURL != url else { return }
        avatarURL = url
        avatarView.image = nil
        Task { [weak self] in
            let image = await ImageLoader.shared.image(from: url)
            guard let self, self.avatarURL == url else { return }
            UIView.transition(with: self.avatarView, duration: 0.25, options: .transitionCrossDissolve) {
                self.avatarView.image = image
            }
        }
    }
}
