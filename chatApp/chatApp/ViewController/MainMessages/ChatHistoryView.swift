//
//  MainMessageView.swift
//  chatApp
//
//  Created by Infoicon on 15/04/24.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct ChatHistoryView: View {
    
    @State var shouldShowLogoutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessageViewModel()
    
    private var chatViewModel = ChatViewModel(chatUser: nil)
    
    var body: some View {
        NavigationView {
            VStack {
                //Custom navigation bar
                customNavBar
                messageView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatView(vm: chatViewModel)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom )
        }
    }
    
    private var customNavBar: some View {
        HStack (spacing: 15){
            
            WebImage(url: URL(string: vm.chatuser?.profileImageUrl ?? ""))
                .resizable()
                .frame(width: 60, height: 60)
                .scaledToFill()
                .clipShape(Circle())
        
            
            VStack(alignment: .leading, spacing: 3) {
                Text("\(vm.chatuser?.email.replacingOccurrences(of: "@gdc.com", with: "") ?? "")")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                HStack {
                    Circle()
                        .foregroundStyle(Color(.green))
                        .frame(width: 12, height: 12)
                    Text("online")
                        .font(.headline)
                        .foregroundStyle(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                shouldShowLogoutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(Color(.label))
            }
            
        }
        .padding()
        .confirmationDialog("Settings \n What do you want to do?", isPresented: $shouldShowLogoutOptions, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                vm.signOutAction()
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, content: {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            })
        })
           
    }
    
    
    
    private var messageView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
//                        Text("Destination")
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(data: [FirebaseConstants.email: recentMessage.email, FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl, FirebaseConstants.uid: uid])
                        self.chatViewModel.chatUser = self.chatUser
                        self.chatViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                            .stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.username)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                    .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text(" + New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundStyle(Color(.white))
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 10)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen, content: {
            NewMessageView(didSelectNewUser: { user in
                //print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatViewModel.chatUser = user
                self.chatViewModel.fetchMessages()
            })
        })
    }
    
    @State var chatUser: ChatUser?
}

#Preview {
    ChatHistoryView()
    //.preferredColorScheme(.dark)
}
