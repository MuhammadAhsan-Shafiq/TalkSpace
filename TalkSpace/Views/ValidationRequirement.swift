//
//  ValidationRequirement.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import SwiftUI

// Validation requirement view used for displaying the validation requirements
struct ValidationRequirement: View {
    var text: String
    var isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            Text(text)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ValidationRequirement(text: "hello", isValid: true)
}
