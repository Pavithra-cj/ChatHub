//
//  MainMessagesView.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-08-10.
//

import SwiftUI

struct MainMessagesView: View {
    var body: some View {
        NavigationView{
            ScrollView{
                HStack{
                    Text("User Profile Image")
                    VStack{
                        Text("User Name")
                        Text("Message")
                    }
                }
            }
            .navigationTitle("Main Messages View")
        }
    }
}

#Preview {
    MainMessagesView()
}
