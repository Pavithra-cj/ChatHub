//
//  ContentView.swift
//  ChatHub
//
//  Created by Pavithra Chamod on 2025-07-26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct LoginView: View {
    
    @State var isLoginMode: Bool = true
    @State var email = ""
    @State var password = ""
    @State var loginStatusMsg = ""
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack(spacing: 12){
                    Picker(selection: $isLoginMode, label: Text("Picker here"))
                    {
                        Text("Login")
                            .tag(true)
                        Text("Signup")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if (!isLoginMode){
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                }else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundStyle(.gray)
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 1))
                        }
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1))
                    
                    Button{
                        handleLogin()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Login" : "Signup")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMsg)
                        .foregroundColor(.red)
                    
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white:0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(
            isPresented: $shouldShowImagePicker,
            onDismiss: nil
        ){
            ImagePicker(image: $image)
        }
    }
    
    private func handleLogin() {
        if isLoginMode{
            print ("Login")
            loginUser()
        }else {
            print ("Signup")
            createNewAccount()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                self.loginStatusMsg = "Failed to login: \(error.localizedDescription)"
                return
            }
            
            print("Loged in successfully!: \(result!.user.uid)")
            self.loginStatusMsg = "User login successfully as: \(result!.user.uid)"
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: \(error.localizedDescription)")
                self.loginStatusMsg = "Failed to create user: \(error.localizedDescription)"
                return
            }
            
            print("User created successfully!: \(result!.user.uid)")
            self.loginStatusMsg = "User created successfully!: \(result!.user.uid)"
        }
    }
    
    private func persistImageToStorage(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil){
            metaData, err in
            if let err = err{
                self.loginStatusMsg = "Failed to upload the image: \(err.localizedDescription)"
                return
            }
            
            ref.downloadURL(){ url, err in
                if let err = err{
                    self.loginStatusMsg = "Failed to download the image URL: \(err.localizedDescription)"
                    return
                }
                
                self.loginStatusMsg = "Image uploaded successfully: \(url!.absoluteString)"
            }
        }
    }
    
}

#Preview {
    LoginView()
}
