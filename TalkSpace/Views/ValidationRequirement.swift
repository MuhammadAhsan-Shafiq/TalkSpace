import SwiftUI

// Validation requirement view used for displaying the validation requirements
struct ValidationRequirement: View {
    var text: String
    var isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? Color.green : Color.red)
            Text(text)
                .font(.footnote)
                .foregroundColor(Color.primary) // Use adaptive color for text
        }
        .padding(.vertical, 2)
    }
}

// Preview for ValidationRequirement
#Preview {
    VStack {
        ValidationRequirement(text: "Valid email address", isValid: true)
        ValidationRequirement(text: "Invalid password", isValid: false)
    }
}
