//
//  NewMessageView.swift
//  chatApp
//
//  Created by Infoicon on 16/04/24.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct NewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(vm.users) { user in
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    }, label: {
                        HStack(spacing: 15) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .frame(width: 50, height: 50)
                                .scaledToFill()
                                .clipShape(Circle())
                                .overlay(RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(.label),lineWidth: 1.0)
                                )
                                
                            Text("\(user.email)")
                                .foregroundStyle(Color(.label))
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        
                    })
                    Divider()
                        .padding(.vertical, 5)
                }
            }
            .navigationTitle("New Message")
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            })
        }
    }
}

#Preview {
    ChatHistoryView()
    //NewMessageView(didSelectNewUser: {user in
    //print(user.email)
    //})
}
