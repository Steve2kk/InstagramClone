//
//  SharePhotoController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 04.02.2021.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage:UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    static let updateFeedNotification = NSNotification.Name("UpdateFeed")
    let imageView:UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView:UITextView = {
       let tv = UITextView()
        tv.font = UIFont.boldSystemFont(ofSize: 14)
        return tv
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupViews()
    }
    
    fileprivate func setupViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    @objc func handleShare() {
       print("Sharing")
        guard let caption = textView.text, !caption.isEmpty else {return}
        guard let image = selectedImage else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}
        navigationItem.rightBarButtonItem?.isEnabled = false
        let fileName = UUID().uuidString
        Storage.storage().reference().child("posts").child(fileName).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("Failed to storage image: ",err)
                return
            }
            Storage.storage().reference().child("posts").child(fileName).downloadURL { (url, err) in
                guard let stringUrl = url?.absoluteString else {return}
                self.saveToDatabaseWithImageUrl(imageUrl: stringUrl)
            }
        }
        
    }
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let caption = textView.text else {return}
        guard let postImage = selectedImage else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl,"caption":caption,"imageWidth":postImage.size.width,"imageHeight":postImage.size.height,"creationDate":Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to database: ",err)
                return
            }
           
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotification, object: nil)
            self.dismiss(animated: true, completion: nil)
            print("success to save all values")
        }
    }
}
