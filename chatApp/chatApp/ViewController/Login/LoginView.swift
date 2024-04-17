//
//  ContentView.swift
//  chatApp
//
//  Created by Infoicon on 12/04/24.
//

import SwiftUI

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    selectionView
                    
                    if !isLoginMode {
                        Button(action: {
                            shouldShowImagePicker.toggle()
                        }, label: {
                            //for showing the selected image
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .tint(.black)
                                    .font(.system(size: 100))
                                    .padding()
                            }
                        }).overlay(RoundedRectangle(cornerRadius: 75)
                            .stroke(Color.black, lineWidth: 3)
                        )
                    }
                    
                    emailPasswordGroup
                   
                    Button {
                        buttonAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundStyle(.white)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundStyle(Color.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil, content: {
            ImagePicker(image: $image)
        }) 
    }
    
    @State var image: UIImage?
    
    private var selectionView: some View {
        Picker(selection: $isLoginMode, label: Text("Picker Here")) {
            Text("Login")
                .tag(true)
            Text("Create Account")
                .tag(false) //highlighted state
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    private var emailPasswordGroup: some View {
        Group{
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $password)
            
        }.padding(12)
            .background(Color.white)
        
    }
    
    private func buttonAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image."
            return 
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user", error.localizedDescription)
                self.loginStatusMessage = "Failed to create user: \(error.localizedDescription)"
                return
            }
            
            print("Successfully registered new user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully registered new user: \(result?.user.uid ?? "")"
            //for uploading pictures to firebase
            //to be implemented only after the user has been created
            self.persistImageToStorage()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login failed \(error.localizedDescription)")
                self.loginStatusMessage = "Login failed \(error.localizedDescription)"
                return
            }
            
            print("Logged in successfully: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Logged in successfully: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
            
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        ref.putData(imageData, metadata: nil) { metaData, error in
            if let error = error {
                self.loginStatusMessage = "Failed to push image to database. \nError : \(error.localizedDescription)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.loginStatusMessage = "Failed to reterive download url. \nError : \(error.localizedDescription)"
                    return
                }
                
                self.loginStatusMessage = ("SuccessFully Uploaded the image. -> \(url?.absoluteString ?? " ")")
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email,
                        "uid": uid,
                        "profileImageUrl": imageProfileUrl.absoluteString
        ]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.loginStatusMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                self.loginStatusMessage = ("SuccessFully uploaded user data.")
            }
    }
    
}

#Preview {
    LoginView(didCompleteLoginProcess: {
        
    })
}
