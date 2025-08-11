//
//  MainMessagesViewModel.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-11.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class MainMessagesViewModel: ObservableObject{
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid
        else {
            self.errorMessage = "Could not find firebase UID"
            return
        }
                
        Firestore.firestore().collection("user").document(uid).getDocument{
 snapshot,
 error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user: \(error)")
                return
            }
            
            guard let data = snapshot?.data()
            else {
                self.errorMessage = "No data found"
                return
            }
            
//            self.errorMessage = "Data: \(data.description)"
            
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let profileImage = data["profileImage"] as? String ?? ""
            
            self.chatUser = ChatUser(
                uid: uid,
                email: email,
                username: username,
                profileImage: profileImage
            )
            
        }
    }
}
