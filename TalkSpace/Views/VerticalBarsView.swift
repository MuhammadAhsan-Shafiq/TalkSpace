//
//  VerticalBarsView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 01/10/2024.
//

import SwiftUI

// MARK: Vertical Bars View
struct VerticalBarsView: View {
    @State private var animationPhase: Double = 0 // pase of animation
    var body: some View {
        HStack(spacing: 4){
            ForEach(0 ..< 5){ index in
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 4, height: CGFloat(20 + (sin(animationPhase + Double(index)) * 20)))// animation height based on sine function
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animationPhase)// animation height change
                    .onAppear{
                        animationPhase += .pi / 2
                    }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VerticalBarsView()
}
