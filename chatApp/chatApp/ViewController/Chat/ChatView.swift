//
//  ChatView.swift
//  chatApp
//
//  Created by Infoicon on 16/04/24.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var vm: ChatViewModel
    
    var body: some View {
        ZStack {
            messageView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        
    }
    
    private var messageView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        VStack {
                            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                HStack {
                                    Spacer()
                                    HStack {
                                        Text (message.text)
                                            .foregroundStyle(Color(.white))
                                    }
                                    .padding()
                                    .background(Color(.blue))
                                    .cornerRadius(10)
                                }
                            } else {
                                HStack {
                                    HStack {
                                        Text (message.text)
                                            .foregroundStyle(Color(.label))
                                    }
                                    .padding()
                                    .background(Color(.white))
                                    .cornerRadius(10)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    
                    HStack { Spacer() }
                        .id("Empty")
                }
                .onReceive(vm.$countVariable) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1.0)))
        .safeAreaInset(edge: .bottom) {
            bottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
        
    }
    
    private var bottomBar: some View {
        HStack(spacing: 15) {
            Button {
                
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(Color(.label))
            }
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                //self.vm.handleSendAction(text: self.vm.chatText)
                self.vm.handleSendAction()
            } label: {
                Text("Send")
                    .padding(10)
                    .background(Color(.systemBlue))
                    .cornerRadius(8)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(.white))
            }
        }.frame(height: 50)
            .padding(.horizontal)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

#Preview {
//    NavigationStack {
//        ChatView(chatuser: .init(data: ["email": "champakLal@gdc.com",
//                                        "uid": "VDrORO6W9hOTM4iojvsks8dsZ4j2",
//                                        "profileImageUrl": "https://firebasestorage.googleapis.com:443/v0/b/chatapp-7ecbf.appspot.com/o/VDrORO6W9hOTM4iojvsks8dsZ4j2?alt=media&token=1fffd1c5-a043-4c8f-9402-cdfc3680f4ea"
//                                       ]
//                                ))
//    }
    
    ChatHistoryView()
    
}
