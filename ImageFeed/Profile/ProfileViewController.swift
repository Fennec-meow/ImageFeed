//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kira on 13.01.2025.
//

import UIKit

final class ProfileViewController: UIViewController {

    private var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar")
        imageView.layer.cornerRadius = 35

        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
        label.textColor = .ypWhite
        return label
    }()
    
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
        label.textColor = .ypGray
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
            let button = UIButton.systemButton(
                with: UIImage(named: "logout_button")!,
                target: self,
                action: #selector(didTapLogoutButton)
            )
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .ypRed
            return button
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContent()
        setupConstraints()
    }
    
    private func setupContent() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        let avatarImageViewConstraints = [
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ]
        let nameLabelConstraints = [
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ]
        let loginNameLabelConstraints = [
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ]
        let descriptionLabelConstraints = [
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor)
        ]
        let logoutButtonConstraints = [
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ]
        
        NSLayoutConstraint.activate(
            avatarImageViewConstraints +
            nameLabelConstraints +
            loginNameLabelConstraints +
            descriptionLabelConstraints +
            logoutButtonConstraints
        )
    }
    
    @objc private func didTapLogoutButton() {
            print("logout_button")
        }
}

