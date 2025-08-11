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
import FirebaseFirestore

struct LoginView: View {
    
    let alreadyLoggedIn: () -> ()
    
    @State private var isLoginMode: Bool = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var username = ""
    @State private var loginStatusMsg = ""
    
    @State private var shouldShowImagePicker = false
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
                        
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                        
                        TextField("Username", text: $username)
                            .autocapitalization(.words)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                        
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
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image{ _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
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
            
            self.alreadyLoggedIn()
        }
    }
    
    private func createNewAccount() {
        guard let originalImage = image else {
            loginStatusMsg = "Please select an profile image!"
            return
        }
        let resizedImage = resizeImage(
            originalImage,
            targetSize: CGSize(width: 150, height: 150)
        )
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.2) else {
            loginStatusMsg = "Failed to process image"
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: \(error.localizedDescription)")
                self.loginStatusMsg = "Failed to create user: \(error.localizedDescription)"
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let userData: [String: Any] = [
                "uid": uid,
                "name": self.name,
                "username": self.username,
                "email": self.email,
                "profileImage": base64Image
            ]
            
            Firestore.firestore().collection("user").document(uid).setData(userData) {
                err in if let err = err {
                    loginStatusMsg = "Failed to save user data: \(err.localizedDescription)"
                    return
                }
            }
            
            print("User created successfully!: \(result!.user.uid)")
            self.loginStatusMsg = "User created successfully!: \(result!.user.uid)"
            
            self.alreadyLoggedIn()
        }
    }
    
    //Have to use Firebase Storage - Should Pay for that
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
    LoginView(alreadyLoggedIn: {
        
    })
}
