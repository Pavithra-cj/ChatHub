//
//  MainMessagesViewModel.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-11.
//

import SwiftUI
import FirebaseAuth

class MainMessagesViewModel: ObservableObject{
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
    }
}
