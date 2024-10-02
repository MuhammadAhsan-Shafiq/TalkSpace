//
//  CustomInputField.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import SwiftUI

// Custom input field used for both email and password inputs
struct CustomInputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isPasswordVisible: Bool? = nil
    var toggleVisibility: (() -> Void)? = nil
    var keyboardType: UIKeyboardType = .default
    var onEditingChanged: ((Bool) -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme // Access current color scheme
    
    var body: some View {
        HStack {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Icon color
            
                    if isSecure, let isPasswordVisible = isPasswordVisible, isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Text color
                    } else if isSecure {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Text color
                    } else {
                        TextField(placeholder, text: $text)
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Text color
                    }
                }
        .keyboardType(keyboardType)
        .autocapitalization(.none)
        .foregroundColor(.black)
        .frame(height: 25)
        .padding(5)
        .background(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7)) // Background color
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)) // Border color
        .overlay(
            HStack {
                Spacer()
                if let isPasswordVisible = isPasswordVisible {
                    Button(action: {
                        toggleVisibility?()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Button icon color
                    }
                    .padding(.trailing, 8)
                }
            }
        )
    }
}


//#Preview {
//    CustomInputField(icon: "", placeholder: "", text: "")
//}
