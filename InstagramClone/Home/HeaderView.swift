//
//  HeaderView.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 13.04.2021.
//

import UIKit

class HeaderView: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel.text = "No posts,yet..."
        addSubview(textLabel)
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
