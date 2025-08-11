//
//  ChatLogView.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-11.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    var body: some View {
        ScrollView{
            ForEach(0..<10) { num in
                Text("Fake Message For Now")
            }
        }
        .navigationTitle(chatUser?.name ?? "")
    }
}

#Preview {
    ChatLogView(chatUser: nil)
}
