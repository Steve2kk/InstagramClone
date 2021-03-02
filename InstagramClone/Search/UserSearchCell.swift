//
//  UserSearchCell.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 21.02.2021.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            guard let url = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: url)
        }
    }
    let profileImageView:CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.text = "username"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 50 / 2
        
        usernameLabel.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, leading: usernameLabel.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
