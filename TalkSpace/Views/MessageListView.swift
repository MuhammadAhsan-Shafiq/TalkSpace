//
//  MessageListView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 30/09/2024.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: ChatViewModel
    var body: some View {
        ScrollViewReader{ scrollViewProxy in
            ScrollView{
                VStack{
                    ForEach(viewModel.messages){ message in
                        HStack{
                            if message.isCurrentUser{
                                Spacer()
                                MessageBubbleView(message: message, viewModel: viewModel)
                            } else{
                                MessageBubbleView(message: message, viewModel: viewModel)
                                Spacer()
                            }
                        }
                        Color.clear.id("bottom")
                    }
                    .padding(.bottom, 10)
                }
                .onChange(of: viewModel.messages.count){
                    withAnimation{
                        scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
        }
    }
}
#Preview {
    MessageListView(viewModel: ChatViewModel())
}
