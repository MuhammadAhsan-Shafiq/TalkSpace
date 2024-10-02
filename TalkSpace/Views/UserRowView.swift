import SwiftUI

// UserRowView
struct UserRowView: View {
    let user: User
    let timeStamp: String? // Add time stamp as parameter
    
    var body: some View {
        HStack {
            // Display initials in a circular shape
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.5), lineWidth: 2)) // Slightly transparent stroke
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                // Display user's name
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary) // Adaptive color
                
                // Conditional display of typing and recording status
                if let isTyping = user.isTyping, isTyping {
                    statusLabel(text: "Typing...", color: .green)
                } else if let isRecording = user.isRecording, isRecording {
                    statusLabel(text: "Recording audio...", color: .orange)
                }
                
                // Display timestamp
                if let displayTimestamp = timeStamp {
                    Text(displayTimestamp)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)
            
            Spacer() // Push the content to the leading side
        }
        .padding(.vertical, 10)
    }
    
    // Helper function to create status labels
    private func statusLabel(text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(color)
            .accessibilityLabel(text) // Accessibility label for the status
    }
}

// Preview for UserRowView
#Preview {
    UserRowView(
        user: User(id: "1", name: "John Doe", email: "john@example.com", isTyping: false, isRecording: false),
        timeStamp: "2 minutes ago" // Add a sample timestamp
    )
}
