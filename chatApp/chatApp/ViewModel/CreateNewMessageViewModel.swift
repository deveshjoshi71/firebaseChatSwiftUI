//
//  CreateNewMessageViewModel.swift
//  chatApp
//
//  Created by Infoicon on 16/04/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch users. \(error.localizedDescription)")
                    self.errorMessage = ("Failed to fetch users. \(error.localizedDescription)")
                    return
                }
                
                documentSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }
                    //self.users.append(.init(data: data))
                })
                
            }
    }
}
