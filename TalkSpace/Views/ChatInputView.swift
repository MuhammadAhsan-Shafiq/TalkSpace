import SwiftUI

// MARK: - Chat Input View
struct ChatInputView: View {
    @Binding var message: String
    var onSend: () -> Void
    @Binding var showImagePicker: Bool
    @Binding var isRecording: Bool
    var onRecordToggle: () -> Void
    var onTypingChange: (Bool) -> Void // Callback for typing status
    
    @State private var showEmojiPicker = false // Track emoji picker state
    @FocusState private var isTextEditorFocused: Bool  // Track text field focus state
    
    @State private var textEditorHeight: CGFloat = 40 // Initial height
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    // Leftmost Emoji button
                    Button(action: {
                        showEmojiPicker.toggle()
                        if showEmojiPicker {
                            isTextEditorFocused = false // Hide text field focus to show emoji picker
                        } else {
                            isTextEditorFocused = true // Show text field when toggling off emoji picker
                        }
                    }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                    
                    // TextEditor with dynamic height
                    TextEditor(text: $message)
                        .focused($isTextEditorFocused)
                        .frame(minHeight: textEditorHeight, maxHeight: textEditorHeight) // Set height limits
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .onChange(of: message) { _ in
                            // Trigger typing status when message changes
                            onTypingChange(!message.trimmingCharacters(in: .whitespaces).isEmpty)
                            // Update height based on text content
                            updateTextEditorHeight()
                        }
                        .onChange(of: isTextEditorFocused) { isFocused in
                            if isFocused {
                                showEmojiPicker = false // Hide emoji picker when text editor is focused
                            }
                        }
                    
                    // Link button to open menu
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 5)
                    
                    // Camera Button
                    Button(action: {
                        // Implement camera functionality here
                    }) {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 10)
                
                // Mic or send button depending on text field content
                HStack {
                    if message.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button(action: {
                            onRecordToggle()
                        }) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 40))
                                .background(Color.white)
                                .foregroundColor(.green)
                                .cornerRadius(30)
                        }
                        .padding()
                    } else {
                        Button(action: {
                            if !message.trimmingCharacters(in: .whitespaces).isEmpty {
                                onSend()
                            }
                        }) {
                            Image(systemName: "paperplane.circle.fill")
                                .font(.system(size: 40))
                                .background(Color.white)
                                .foregroundColor(.green)
                                .cornerRadius(30)
                        }
                        .padding()
                    }
                }
            }
            .padding([.leading, .bottom])
            // Custom Emoji Picker View
            if showEmojiPicker {
                EmojiPickerView(selectedEmoji: $message)
                    .frame(height: 200)
            }
        }
    }
    private func updateTextEditorHeight() {
        // Measure the height of the text content
        let size = message.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity),
                                         options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                                         attributes: [.font: UIFont.systemFont(ofSize: 17)],
                                         context: nil).size
        // Update height to accommodate at least one line
        textEditorHeight = max(size.height + 20, 40) // Minimum height set to 40
    }
}

// MARK: - Emoji Picker View
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    
    // Define a basic set of emojis for selection
    let emojis = [
        // Smileys & Emotion
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😜", "😝", "😋",
        "😎", "😍", "😘", "😗", "😙", "😚", "🙂", "🙃", "😉", "😇", "🥰",
        "🥳", "😌", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "😣", "😖",
        "😫", "😩", "😢", "😭", "😤", "😠", "😡", "😶", "😐", "😯", "😦",
        "😧", "😮", "😲", "😳", "😵", "😱", "😨", "😰", "😥", "😓", "🤗",
        "🤔", "🤭", "🤫", "🤥", "😶‍🌫️", "😯‍🌫️", "😴", "🥱", "😬", "🤐",
        "🤨", "🧐", "🤓", "😈", "👿", "👹", "👺", "💀", "☠️", "👻", "👽",
        "🤖", "😺", "😸", "😻", "😼", "😽", "🙀", "😿", "😾", "🤲", "👐",
        "🙌", "👏", "🤝", "👍", "👎", "✊", "👊", "🤛", "🤜", "✋", "🖐",
        "🖖", "👌", "🤏", "✌️", "🤟", "🤘", "💪", "🦵", "🦶", "👂", "🦻",
        "👃", "👋", "👈", "👉", "👆", "🖕", "👇", "🖖", "👐", "🤲", "🤝",
        
        // Animals & Nature
        "🐶", "🐕", "🐩", "🐺", "🐱", "🐈", "🐈‍⬛", "🐾", "🐭", "🐹", "🐰",
        "🐇", "🐿️", "🦊", "🦝", "🦄", "🐴", "🦓", "🐮", "🐷", "🐗", "🐵",
        "🐒", "🐣", "🦅", "🦉", "🦤", "🦇", "🐞", "🐜", "🐝", "🐛", "🦋",
        "🐌", "🐚", "🐢", "🐍", "🦎", "🦖", "🐙", "🐠", "🐡", "🦐", "🦞",
        "🦀", "🐚", "🐳", "🐬", "🐋", "🦈", "🐊", "🐅", "🐆", "🐘", "🦏",
        "🐫", "🐪", "🦒", "🐃", "🐂", "🐏", "🐑", "🐐", "🐓", "🦃", "🐦",
        "🐥", "🐧", "🐦", "🦇", "🐉", "🐲", "🦚", "🦩", "🐣",
        
        // Food & Drink
        "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒",
        "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥕", "🥔", "🌽", "🥒", "🥬",
        "🥦", "🍄", "🍞", "🥖", "🥯", "🥨", "🥯", "🥗", "🍗", "🍖", "🍔",
        "🍟", "🌭", "🍕", "🥪", "🌮", "🌯", "🥙", "🍝", "🍜", "🍲", "🍣",
        "🍱", "🍛", "🍚", "🍙", "🥟", "🍥", "🍧", "🍨", "🍦", "🍩", "🍪",
        "🎂", "🍰", "🧁", "🍫", "🍬", "🍭", "🍮", "🍯", "🍼", "🥛", "☕",
        "🍵", "🍶", "🍾", "🍷", "🍸", "🍹", "🍺", "🥃", "🥤", "🍽️",
        
        // Travel & Places
        "🏠", "🏡", "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "💒", "🏛️",
        "🗽", "🗼", "🏗️", "🌉", "🌁", "🏞️", "🌅", "🌄", "🌌", "🗻", "🏔️",
        "⛰️", "🏕️", "🏖️", "🏝️", "🏜️", "🏟️", "🏛️", "🏛️", "🎡", "🎢",
        "🎠", "🚂", "🚉", "🚆", "🚅", "🚄", "🚍", "🚎", "🚏", "🚌", "🚐",
        "🚘", "🚗", "🚙", "🚖", "🚔", "🚍", "🚲", "🛴", "🛵", "🏍️", "🚤",
        "🚢", "✈️", "🛩️", "🛫", "🛬", "🛳️", "🚀", "🛰️", "🛸",
        
        // Activities
        "⚽", "🏀", "🏈", "⚾", "🎾", "🏐", "🏉", "🎱", "🎳", "🏓", "🏸",
        "🪃", "🥇", "🥈", "🥉", "🏆", "🏅", "🎖️", "🎗️", "🎟️", "🎫", "🎭",
        "🎨", "🎬", "🎤", "🎧", "🎼", "🎵", "🎶", "🎷", "🎺", "🎸", "🪕",
        "🪗", "🥁", "🎻", "🎺", "🎤", "🎧", "🎼", "🎷", "🎸", "🎵", "🎶",
        
        // Symbols
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "💖",
        "💗", "💓", "💞", "💕", "💌", "💋", "💍", "💎", "⚡", "🔥", "✨",
        "🌟", "💫", "🌈", "☔", "💧", "🌊", "🍀", "🌱", "🌿", "🌾", "🍃",
        "🌍", "🌎", "🌏", "🌐", "💢", "♻️", "⚜️", "🔝", "🔙", "🔛", "🔜",
        "🔝", "⚠️", "🚫", "❌", "✅", "🔞", "🔴", "🟠", "🟡", "🟢", "🔵",
        "🟣", "⚪", "⚫", "🔘", "🔲", "🔳", "◼️", "◻️", "◾", "◽", "🔲",
        "🔳", "🔈", "🔉", "🔊", "📣", "📢", "📯", "🔔", "🎺", "🎷", "🎸",
        "🎤", "🎶", "🎵", "🎼", "🎧", "🎻", "🪕", "🪗", "🥁", "🎶", "🎵",
        
        // Flags
        "🏳️", "🏴", "🏁", "🚩", "🇦🇫", "🇦🇱", "🇩🇿", "🇦🇸", "🇩🇪", "🇦🇬",
        "🇦🇷", "🇦🇲", "🇦🇼", "🇧🇧", "🇧🇪", "🇧🇷", "🇧🇴", "🇧🇾", "🇧🇿", "🇻🇬",
        "🇻🇪", "🇻🇳", "🇭🇰", "🇭🇹", "🇭🇺", "🇮🇩", "🇮🇳", "🇮🇱", "🇮🇹", "🇯🇵",
        "🇯🇱", "🇰🇷", "🇰🇷", "🇱🇰", "🇲🇽", "🇲🇩", "🇲🇦", "🇲🇨", "🇲🇾", "🇲🇻",
        "🇵🇰", "🇵🇷", "🇶🇦", "🇷🇺", "🇸🇦", "🇸🇬", "🇸🇪", "🇸🇿", "🇹🇭", "🇹🇷",
        "🇻🇺", "🇾🇪", "🇿🇦", "🇿🇲", "🇿🇼"
    ]
    
    
    let columns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.largeTitle)
                        .onTapGesture {
                            selectedEmoji += emoji // Append the emoji to the message
                        }
                }
            }
            .padding()
        }
        .frame(height: 250)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


// Preview for ChatInputView
#Preview {
    @State var message = ""
    @State var showImagePicker = false
    @State var isRecording = false
    
    return ChatInputView(
        message: $message,
        onSend: { print("Message sent: \(message)") },
        showImagePicker: $showImagePicker,
        isRecording: $isRecording,
        onRecordToggle: { isRecording.toggle() },
        onTypingChange: { isTyping in print("User typing: \(isTyping)") }
    )
}
