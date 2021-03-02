//
//  CommentsController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 27.02.2021.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    let cellID = "cellID"
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(CommentsCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.backgroundColor = .white
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
   
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, leading: nil, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: submitButton.leadingAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let lineSeparator = UIView()
        lineSeparator.backgroundColor = .init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerView.addSubview(lineSeparator)
        lineSeparator.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else {return}
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded,with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            Database.fetchUserWithUID(uid: uid) { (user) in
                let comment = Comment(user: user,dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }){(err) in
                print("Failed to observe comments: ",err)
        }
    }
    
    
    @objc func handleSendComment() {
        guard let postID = self.post?.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["text": commentTextField.text ?? "","creationDate" : Date().timeIntervalSince1970,"uid" : uid] as [String:Any]
        Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(values){ (err,ref) in
            if let err = err {
                print("Failed to add comment:",err)
                return
            }
            print("Successfully summited comment")
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentsCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let resizableCell = CommentsCell(frame: frame)
        resizableCell.comment = comments[indexPath.item]
        resizableCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = resizableCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
