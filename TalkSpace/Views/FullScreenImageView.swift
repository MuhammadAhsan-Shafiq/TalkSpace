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
                // Placeholder with adaptive style
                ZStack {
                    Color(UIColor.systemGray6) // Use a system gray color
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            
          
            // Close button in the top-right corner
            Button(action: {
                withAnimation(.spring()) {
                    isFullScreen = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 30))
                    .padding()
                    .background(Color.black.opacity(0.3)) // Background to ensure visibility
                    .clipShape(Circle())
            }
            .padding([.top, .trailing], 20) // Add spacing from the top and trailing edges
        }
    }
}

#Preview {
    FullScreenImageView(imageUrl: "https://example.com/sample-image.jpg", isFullScreen: .constant(true), namespace: Namespace().wrappedValue)
}
