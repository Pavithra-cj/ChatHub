//
//  ChatLogViewModel.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-14.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        Firestore
            .firestore()
            .collection("chats")
            .document(fromId)
            .collection(toId)
            .order(by: "timeStamp")
            .addSnapshotListener { querySnapshot,error in
                if let error = error {
                print("Error listening for changes: \(error.localizedDescription)")
                self.errorMessage = "Faield to fetch messages: \(error.localizedDescription)"
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    
                    self.chatMessages
                        .append(
                            .init(
                                documentId: change.document.documentID,
                                data: data
                            )
                        )
                }
            })
        }
    }
    
    func handleSendMessage() {
        print(chatText)
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = Firestore.firestore().collection("chats").document(fromId).collection(toId).document()
        
        let recipientMessageDocument = Firestore.firestore().collection("chats").document(toId).collection(fromId).document()
        
        let messageData = [
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.message: self.chatText,
            "timeStamp": Timestamp()
        ] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message: \(error.localizedDescription)"
                return
            }
            
            print("Successfully saved message")
            self.chatText = ""
        }
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message: \(error.localizedDescription)"
                return
            }
            
            print("Recipeient successfully saved message")
        }
    }
    
}
