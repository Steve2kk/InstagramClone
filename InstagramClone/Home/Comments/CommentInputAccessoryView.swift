//
//  CommentInputAccessoryView.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 02.03.2021.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        return button
    }()
    
    fileprivate let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        addSubview(submitButton)
        addSubview(commentTextView)
        submitButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        commentTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: submitButton.leadingAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeparatorView()
    }
    
    func clearCommentTextField() {
        commentTextView.text = nil
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = .init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSendComment() {
        guard let commentText = commentTextView.text else {return}
        delegate?.didSubmit(for: commentText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
