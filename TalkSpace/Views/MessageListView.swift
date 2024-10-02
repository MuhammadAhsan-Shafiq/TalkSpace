import SwiftUI

struct MessageListView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isCurrentUser {
                                Spacer()
                                MessageBubbleView(message: message, viewModel: viewModel)
                            } else {
                                MessageBubbleView(message: message, viewModel: viewModel)
                                Spacer()
                            }
                        }
                        Color.clear.id("bottom")
                    }
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Preview for MessageListView
#Preview {
    MessageListView(viewModel: ChatViewModel())
}
