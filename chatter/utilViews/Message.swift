//
//  MessageView.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import SwiftUI


struct Message: View, Identifiable, Equatable {
    let id: UUID
    let isUser: Bool
    var text: String
    
    init(id: UUID = UUID(), isUser: Bool, text: String) {
        self.id = id
        self.isUser = isUser
        self.text = text
    }
    
    var body: some View {
        HStack {
            if isUser {
                Spacer(minLength: 80)
                querry
            } else {
                bubble
                    .frame(width: .infinity, alignment: .leading)
            }
        }
    }
    
    var querry: some View {
        SelectableText(text, color: .white)
            .font(.body)
            .textSelection(.enabled)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .foregroundStyle(.blue)
            )
    }
    
    var bubble: some View {
        SelectableText(
            text.isEmpty ? "..." : text,
            color: .label
        )
        .font(.body)
        .textSelection(.enabled)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

extension Message {
    static var mock: Message {
        Message(isUser: false, text: "")
    }
}

#Preview {
    Message(id: UUID(), isUser: true, text: "Hello")
}
