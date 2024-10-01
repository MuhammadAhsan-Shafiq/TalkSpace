//
//  SpeechBubbleShape.swift
//  TalkSpace
//
//  Created by MacBook Pro on 30/09/2024.
//

import SwiftUI

// MARK: - Custom Speech Bubble Shape
struct SpeechBubbleShape: Shape {
    var isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isCurrentUser {
            path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + 20), control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 20))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.maxY), control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
            path.addLine(to: CGPoint(x: rect.maxX + 10, y: rect.maxY - 10)) // Extended outward
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 30)) // Adjusted height for tail
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 20))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.minY), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.minY))
        } else {
            path.move(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 20), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 20))
            path.addLine(to: CGPoint(x: rect.minX - 10, y: rect.maxY - 10)) // Extended outward
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 30)) // Adjusted height for tail
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 20))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
        }
        
        return path
    }
}


#Preview {
    SpeechBubbleShape(isCurrentUser: true)
}
