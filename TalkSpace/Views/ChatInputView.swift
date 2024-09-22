//
//  ChatInputView.swift
//  TalkSpace
//
//  Created by MacBook Pro on 22/09/2024.
//

import SwiftUI

// MARK: - Chat Input View
struct ChatInputView: View {
    @Binding var message: String
    var onSend: () -> Void
    @Binding var showImagePicker: Bool
    @Binding var isRecording: Bool
    var onRecordToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { showImagePicker = true }) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .padding(.leading)
            
            TextField("Message...", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight: 30)
                .padding(5)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            if isRecording {
                Button(action: onRecordToggle) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    onRecordToggle()
                }) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
            
            
            
            Button(action: {
                if !message.isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .foregroundColor(message.isEmpty ? .gray : .blue)
                
            }
            .disabled(message.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


// Preview for ChatInputView
#Preview {
    ChatInputView(message: .constant(""), onSend: {}, showImagePicker: .constant(false), isRecording: .constant(false), onRecordToggle: {})
}
