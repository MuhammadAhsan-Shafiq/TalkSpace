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
    
    var body: some View {
        HStack {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)

                    if isSecure, let isPasswordVisible = isPasswordVisible, isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
        .keyboardType(keyboardType)
        .autocapitalization(.none)
        .foregroundColor(.black)
        .frame(height: 25)
        .padding(5)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
        .overlay(
            HStack {
                Spacer()
                if let isPasswordVisible = isPasswordVisible {
                    Button(action: {
                        toggleVisibility?()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.black)
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
