//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 25.01.2021.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            setupEditFollowButton()
        }
    }
    var numberOfPosts: Int? {
        didSet {
            let attributedText = NSMutableAttributedString(string: "\(String(describing: numberOfPosts ?? 0)) \n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.lightGray.cgColor]))
            postsLabel.attributedText = attributedText
        }
    }
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 80 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleListView), for: .touchUpInside)
        return button
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    let postsLabel:UILabel = {
       let label = UILabel()
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followersLabel:UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.lightGray.cgColor]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel:UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.lightGray.cgColor]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var editProfileFollowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if currentLoggedInUserId == userId {
            //edit profile
            editProfileFollowButton.isEnabled = false
            
        }else {
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int,isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("UnFollow", for: .normal)
                }else {
                    self.setupFollowStyle()
                }
            }, withCancel: { (err) in
                print("failed to check following:",err)
            })
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor.init(white: 0, alpha: 0.2).cgColor
    }
    
    @objc func handleEditProfileOrFollow() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:",err)
                }
                self.setupFollowStyle()
            }
        }else {
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            let values = [userId : 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user: ", err)
                }
                print("Successfully followed user: ",self.user?.username ?? "")
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    @objc func handleListView() {
        listButton.tintColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        gridButton.tintColor = .init(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    @objc func handleGridView() {
        listButton.tintColor = .init(white: 0, alpha: 0.2)
        gridButton.tintColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        delegate?.didChangeToGridView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, leading: profileImageView.leadingAnchor, bottom: nil, trailing: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let bottomStackView = UIStackView(arrangedSubviews: [gridButton,listButton,favoriteButton])
        addSubview(bottomStackView)
        bottomStackView.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        bottomStackView.distribution = .fillEqually
        
        let userInfoStackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        addSubview(userInfoStackView)
        userInfoStackView.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: nil, trailing: trailingAnchor , paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
        userInfoStackView.distribution = .fillEqually
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: userInfoStackView.bottomAnchor, leading: userInfoStackView.leadingAnchor, bottom: nil, trailing: userInfoStackView.trailingAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        
        let topDividerView = UIView()
        let bottomDividerView = UIView()
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        topDividerView.anchor(top: bottomStackView.topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        topDividerView.backgroundColor = .lightGray
        bottomDividerView.anchor(top: bottomStackView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
