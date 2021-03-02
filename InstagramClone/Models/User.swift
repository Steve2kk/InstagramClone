//
//  USe.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 25.01.2021.
//

import Foundation
struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String,dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profile_image"]  as? String ?? ""
    }
}
