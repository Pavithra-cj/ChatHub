//
//  MainMessageModel.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-11.
//

import Foundation
import SwiftUI

struct ChatUser: Identifiable {
    var id: String { uid }
    
    let uid: String
    let email: String
    let username: String
    let name: String
    let profileImage: String?
    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.profileImage = data["profileImage"] as? String ?? ""
    }
}
