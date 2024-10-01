import SwiftUI

// UserRowView
struct UserRowView: View {
    let user: User
    let timeStamp: String? // add time stamp as parameter
    
    var body: some View {
        HStack {
            // Display initials in a circular shape
            Text(user.initials)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                // Display user's name
                Text(user.name)
                    .font(.headline)
                
                // Conditional display of typing and recording status or last message
                HStack {
                    if let isTyping = user.isTyping, isTyping {
                        Text("Typing...")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else if let isRecording = user.isRecording, isRecording {
                        Text("Recording audio...")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } 
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
}

#Preview {
    UserRowView(
        user: User(id: "1", name: "John Doe", email: "john@example.com", isTyping: false, isRecording: false),
        timeStamp: "2 minutes ago" // Add a sample timestamp
    )
}
