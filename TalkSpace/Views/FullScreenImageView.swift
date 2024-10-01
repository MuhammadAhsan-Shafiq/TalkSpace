//
//  FullScreenImageView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 30/09/2024.
//

import SwiftUI



struct FullScreenImageView: View {
    let imageUrl: String
    @Binding var isFullScreen: Bool
    var namespace: Namespace.ID // Recieved the shared namespace
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: imageUrl)){ image in
                image
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "chatImage", in: namespace) // apply the matched geometry effect
                    .onTapGesture {
                        withAnimation(.spring()){
                            isFullScreen = false
                        }
                    }
            } placeholder: {
                ProgressView()
            }
            
            Button(action: {
                withAnimation(.spring()){
                    isFullScreen = false
                }
            }){
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 30))
                    .padding()
            }
        }
    }
}


//#Preview {
//    FullScreenImageView(imageUrl: imageUrl, isFullScreen: <#Binding<Bool>#>, namespace: <#Namespace.ID#>)
//}
