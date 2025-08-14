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
    
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
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
            
            self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut(){
        do {
            try Auth.auth().signOut()
            isUserCurrentlyLoggedOut.toggle()
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
