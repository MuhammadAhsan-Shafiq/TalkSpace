import SwiftUI

// MARK: Vertical Bars View
struct VerticalBarsView: View {
    @State private var animationPhase: Double = 0 // phase of animation
    @Environment(\.colorScheme) var colorScheme // Access the current color scheme

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< 5) { index in
                Rectangle()
                    .fill(barColor) // Use dynamic color based on the color scheme
                    .frame(width: 4, height: CGFloat(20 + (sin(animationPhase + Double(index)) * 20))) // animation height based on sine function
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animationPhase) // animation height change
                    .onAppear {
                        animationPhase += .pi / 2
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // Dynamic color based on the color scheme
    private var barColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : Color.green // Adjust opacity for dark mode
    }
}

// MARK: - Preview
#Preview {
    VerticalBarsView()
}
