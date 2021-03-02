//
//  Comment.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 28.02.2021.
//

import Foundation

struct Comment {
    
    let text: String
    let uid: String
    let user: User
    
    init(user: User,dictionary: [String:Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
