//
//  Post.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 04.02.2021.
//

import Foundation

struct Post {
    var id: String?
    let imageUrl: String
    let user: User
    let caption: String
    var hasLiked = false
    let creationDate: Date
    
    init(user: User,dictionary: [String:Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
