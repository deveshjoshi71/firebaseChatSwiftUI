//
//  ChatViewModel.swift
//  chatApp
//
//  Created by Infoicon on 17/04/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    @Published var countVariable = 0
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error.localizedDescription)"
                    //print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    
                    if change.type == .added {
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(cm)
                            print("Appending chatMessage in ChatLogView: \(Date())")
                        } catch {
                            print("Failed to decode message: \(error)")
                        }

                    }
                })
                
                DispatchQueue.main.async {
                    self.countVariable += 1
                }
                
            }
    }
    
    func handleSendAction() {
        //print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId =  chatUser?.uid else { return }
        
        //saving message to FireStore
        let currentUserDocument = FirebaseManager.shared.firestore
                                    .collection("messages")
                                    .document(fromId)
                                    .collection(toId)
                                    .document()
        
        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())

        
        try? currentUserDocument.setData(from: msg) { error in
            if let error = error {
                self.errorMessage = "Failed to save message to Firestore: \(error.localizedDescription)"
                //print("Failed to save message to Firestore: \(error.localizedDescription)")
                return
            }
            
            print("Successfully saved current user message.")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.countVariable += 1
        }
        
        let recipientsDocument = FirebaseManager.shared.firestore
                                    .collection("messages")
                                    .document(toId)
                                    .collection(fromId)
                                    .document()
        
        try? recipientsDocument.setData(from: msg) { error in
            if let error = error {
                self.errorMessage = "Failed to save message to Firestore: \(error.localizedDescription)"
                //print("Failed to save message to Firestore: \(error.localizedDescription)")
                return
            }
            
            print("Successfully saved recipient message.")
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.email: currentUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
        
    }
}
