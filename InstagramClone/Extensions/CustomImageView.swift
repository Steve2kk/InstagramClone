//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 05.02.2021.
//

import UIKit

var imageCashe = [String:UIImage]()
class CustomImageView: UIImageView {
    
    var lastUsedUrlToLoadImage: String?
    
    func loadImage(urlString: String) {
        self.image = nil
        if let cashedImage = imageCashe[urlString] {
            self.image = cashedImage
            return 
        }
        
        guard let url = URL(string: urlString) else { return }
        
        lastUsedUrlToLoadImage = urlString
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            
            if url.absoluteString != self.lastUsedUrlToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            imageCashe[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
        }.resume()
    }
}
