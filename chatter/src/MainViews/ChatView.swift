//
//  ChatView.swift
//  chatter
//
//  Created by Тимофей Фролов on 24.04.2026.
//

import SwiftUI


struct ChatView: View {
    
    
    @State var languageModelController: LanguageModelController
    
    @State var scrollPosotion = ScrollPosition(edge: .bottom)
    @State var isAtBottom: Bool = true
    
    @FocusState var textFieldIsFocused: Bool
    @State var textFieldContent: String = ""
    
    @State var showScrollDownButton: Bool = false
    @State var showCancellGenerationButton: Bool = false
    @State var showSendButton: Bool = false
    @State var keyboardIsOppened: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(languageModelController.chatHistory, id: \.id) { message in
                    message
                }
                
                if let error = languageModelController.error {
                    Text(error.localizedDescription)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
        }
        .scrollPosition($scrollPosotion)
        .onScrollGeometryChange(for: Bool.self) { geo in
            let height = geo.contentSize.height
            let offset = geo.contentOffset.y
            let insetTop = geo.contentInsets.top
            let container = geo.containerSize.height
            
            let distanceToBottom = height - offset - insetTop - container - 90
            
            return distanceToBottom < 0
        } action: { _, atBottom in
            isAtBottom = atBottom
        }
        .onChange(of: languageModelController.chatHistory.count) { _, newValue in
            if isAtBottom { scrollToBottom(animate: true) }
        }
        .onChange(of: languageModelController.chatHistory.last?.text.count ?? 0) {
            if isAtBottom { scrollToBottom(animate: false) }
        }
        .onTapGesture { textFieldIsFocused = false }
        .onChange(of: textFieldIsFocused) { oldValue, newValue in
            if isAtBottom { scrollToBottom(animate: true) }
        }
        .safeAreaInset(edge: .top){
            topBar
                .padding(.bottom, 2)
                .background {
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemBackground),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
        }
        .safeAreaInset(edge: .bottom) {
            composer
        }
        .onDisappear { languageModelController.cancelGeneration() }
    }
    
    
    private var topBar: some View {
        GlassEffectContainer {
            HStack {
                Text("Agenticus")
                    .font(.title3.width(.expanded).weight(.medium))
                
                Spacer()
                
                Button {
                    languageModelController.cancelGeneration()
                    languageModelController.clearChat()
                } label: {
                    Text("Clear")
                        .font(.body)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal)
        }
    }
    
    
    @Namespace private var ComposerNamespace
    
    private var composer: some View {
        GlassEffectContainer(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Prompt", text: $textFieldContent, axis: .vertical)
                        .focused($textFieldIsFocused)
                        .lineLimit(1...6)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            textFieldIsFocused = true
                        }
                        .glassEffect(
                            .regular.interactive(),
                            in: RoundedRectangle(cornerRadius: 24)
                        )
                        .glassEffectID("textfield", in: ComposerNamespace)
                    
                    if showCancellGenerationButton {
                        Button {
                            languageModelController.cancelGeneration()
                        } label: {
                            Image(systemName: "stop.fill")
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                        .frame(width: 48, height: 48)
                        .glassEffectID("StopButton", in: ComposerNamespace)
                    }
                    
                    if showSendButton {
                        Button {
                            languageModelController.taskResponse(
                                to: textFieldContent.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                            textFieldContent.removeAll()
                        } label: {
                            Image(systemName: "arrow.up")
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                        .frame(width: 48, height: 48)
                        .glassEffectID("SendButton", in: ComposerNamespace)
                        .disabled(languageModelController.isResponding)
                    }
                }
                
                if showScrollDownButton {
                    Button {
                        scrollToBottom()
                    } label: {
                        Image(systemName: "chevron.down")
                            .frame(width: 32, height: 32)
                            .offset(x: 0, y: 1)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .frame(width: 48, height: 48)
                    .frame(height: 0, alignment: .bottom)
                    .glassEffectID("ScrollDownButton", in: ComposerNamespace)
                    .offset(x: 0, y: -56)
                }
            }
            .padding(.horizontal, keyboardIsOppened ? 12 : 32)
            .padding(.bottom, keyboardIsOppened ? 12 : 0)
            .onChange(of: textFieldIsFocused) { _, newValue in
                withAnimation(.smooth) { keyboardIsOppened = newValue }
            }
            .onChange(of: !textFieldContent.isEmpty) { _, newValue in
                withAnimation(.smooth) { showSendButton = newValue }
            }
            .onChange(of: languageModelController.isResponding) { _, newValue in
                withAnimation(.smooth) { showCancellGenerationButton = newValue }
            }
            .onChange(of: !isAtBottom) { _, newValue in
                withAnimation(.smooth) { showScrollDownButton = newValue }
            }
        }
    }
    
    
    private func scrollToBottom(animate: Bool = true) {
        if animate {
            withAnimation(.easeOut(duration: 0.3)) {
                scrollPosotion.scrollTo(edge: .bottom)
            }
        } else {
            scrollPosotion.scrollTo(edge: .bottom)
        }
    }
}


#Preview {
    ContentView.testInit()
}
