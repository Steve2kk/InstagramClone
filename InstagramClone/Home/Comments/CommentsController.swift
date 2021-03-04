//
//  CommentsController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 27.02.2021.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController,UICollectionViewDelegateFlowLayout,CommentInputAccessoryViewDelegate {
    
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
   
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputAccessoryView = CommentInputAccessoryView(frame: frame)
        inputAccessoryView.delegate = self
        return inputAccessoryView
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
    
    func didSubmit(for comment: String) {
        guard let postID = self.post?.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["text": comment,"creationDate" : Date().timeIntervalSince1970,"uid" : uid] as [String:Any]
        Database.database().reference().child("comments").child(postID).childByAutoId().updateChildValues(values){ (err,ref) in
            if let err = err {
                print("Failed to add comment:",err)
                return
            }
            self.containerView.clearCommentTextField()
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
    
    //MARK: collectionView setups
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
