//
//  AudioVisualizerView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 30/09/2024.
//

import SwiftUI

struct AudioVisualizerView: View {
    @Binding var audioLevel: Float // Binding to the audio level from ChaViewModel
    
    private let numberOfBars: Int = 20 // number of bars in the visualizer
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: barSpacing){
            ForEach(0..<numberOfBars, id: \.self){ index in
                BarView(audioLevel: audioLevel, index: index, numberOfBars: numberOfBars)
            }
        }
        .frame(height: 100)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct BarView: View {
    var audioLevel: Float
    var index: Int
    var numberOfBars: Int

    var body: some View {
        let normalizedLevel = CGFloat(max(0, min(1, (audioLevel + 160) / 160)))
        let barHeight = 100 * normalizedLevel // Use normalized level directly

        return Rectangle()
            .fill(Color.green)
            .frame(width: 4, height: barHeight)
            .cornerRadius(2)
            .animation(.linear(duration: 0.1), value: barHeight)
            .accessibilityLabel("Audio level at bar \(index + 1): \(Int(normalizedLevel * 100)) percent") // Accessibility label
    }
}
// Preview for AudioVisualizerView
#Preview {
    @Previewable @State var audioLevel: Float = 0.0 // Example audio level for preview
    AudioVisualizerView(audioLevel: $audioLevel)
}

