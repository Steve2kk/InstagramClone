//
//  HomePostCell.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 11.02.2021.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell:HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet{
            guard let postImageUrl = post?.imageUrl else {return}
            photoImageView.loadImage(urlString: postImageUrl)
            usernameLabel.text = post?.user.username
            guard let profileImageUrl = post?.user.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: profileImageUrl)
            setupAttributedText()
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    let userProfileImageView:CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let optionButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleOpenComments), for: .touchUpInside)
        return button
    }()
    
    let sendMessageButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2-1").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let favoritedPhotoButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(photoImageView)
        addSubview(optionButton)
        addSubview(captionLabel)
        
        userProfileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 36, height: 36)
        userProfileImageView.layer.cornerRadius = 36/2
        usernameLabel.anchor(top: topAnchor, leading: userProfileImageView.trailingAnchor, bottom: photoImageView.topAnchor, trailing: optionButton.leadingAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        optionButton.anchor(top: topAnchor, leading: nil, bottom: photoImageView.topAnchor, trailing: trailingAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 44, height: 0)
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        setupActionButtons()
        captionLabel.anchor(top: likeButton.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupAttributedText() {
        guard let post = self.post else {return}
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption  )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.gray]))
        captionLabel.attributedText = attributedText
    }
    
    func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,sendMessageButton])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        addSubview(favoritedPhotoButton)
        favoritedPhotoButton.anchor(top: photoImageView.bottomAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
    }
    
    //MARK: objc methods
    @objc func handleOpenComments() {
        guard let post = post else {return}
        delegate?.didTapComment(post: post)
    }
    
    @objc func handleLike() {
        print("Handling likes")
        delegate?.didLike(for: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
