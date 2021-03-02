//
//  UserProfileController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 15.01.2021.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController,UICollectionViewDelegateFlowLayout,UserProfileHeaderDelegate {
   
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var user: User?
    var userId: String?
    var posts = [Post]()
    var isGridView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotification, object: nil)
        fetchUser()
        collectionViewSetups()
        setupLogOutButton()
    }
    
    fileprivate func collectionViewSetups() {
        collectionView?.backgroundColor = .white
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView.register(PostCellView.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    fileprivate func fetchUser() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            if user.uid == Auth.auth().currentUser?.uid {
                self.navigationItem.title = self.user?.username
            }
            self.collectionView.reloadData()
            self.paginationPosts()
        }
    }
     
    var isFinishedPaging = false
    
    fileprivate func paginationPosts() {
        guard let uid = self.user?.uid else {return}
        
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value,with: { (snapshot) in
            guard let user = self.user else {return}
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
           
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            })
            self.collectionView.reloadData()
        }){ (err) in
            print("Failed to paginate posts: ",err)
        }
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchUser()
    }
    
//    fileprivate func fetchPosts() {
//        guard let uid = self.user?.uid else { return }
//        let ref = Database.database().reference().child("posts").child(uid)
//
//        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//            guard let user = self.user else {return}
//
//            let post = Post(user: user,dictionary: dictionary)
//            self.posts.insert(post, at: 0)
//
//            self.collectionView?.reloadData()
//        }) { (err) in
//            print("Failed to fetch ordered posts:", err)
//        }
//
//    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (_) in
            do {
                try  Auth.auth().signOut()
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }catch let signOutErr {
                print("Failed to sign out: ",signOutErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- collectionView setups
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! UserProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == self.posts.count - 1) && !isFinishedPaging {
            paginationPosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostCellView
            cell.post = posts[indexPath.item]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }else {
            var height:CGFloat = 36 + 8 + 8
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

