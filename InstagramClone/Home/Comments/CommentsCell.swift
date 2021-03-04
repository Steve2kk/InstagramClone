//
//  CommentsCell.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 28.02.2021.
//

import UIKit

class CommentsCell: UICollectionViewCell{
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else {return}
            
            let attributedText = NSMutableAttributedString(string: "\(comment.user.username) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: comment.text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = attributedText
            
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let textView: UITextView = {
       let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(textView)
        
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        textView.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
