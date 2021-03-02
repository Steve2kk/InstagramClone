//
//  PreviewPhotoContainerView.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 27.02.2021.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView:UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
        guard let previewImage = previewImageView.image else {return}
        
        let library = PHPhotoLibrary.shared()
        library.performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        } completionHandler: { (success, err) in
            if let err = err {
                print("Failed to save image to photo library:",err)
            }
            print("Successfully save image to library")
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.frame = CGRect(x: 0, y: 0, width: 190, height: 80)
                savedLabel.text = "Saved successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 16)
                savedLabel.numberOfLines = 0
                savedLabel.textColor = .white
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
                savedLabel.center = self.center
                savedLabel.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
                self.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                } completion: { (completed) in
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                    } completion: { (_) in
                        savedLabel.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        saveButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
