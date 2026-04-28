//
//  ModelManager.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import Foundation
import FoundationModels
import Observation
import SwiftUI


extension SystemLanguageModel.Availability.UnavailableReason: @retroactive Error {}


@Observable
final class LanguageModelController {
    
    @ObservationIgnored private static let useInstructionsDefault: Bool = true
    @ObservationIgnored private static let instructions: String? = nil
    
    var session: LanguageModelSession
    var generationTask: Task<Void, Never>?
    var error: Error? = nil
    var chatHistory: [Message] = []

    init() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            self.session = Self.newSession(useInstructions: Self.useInstructionsDefault)
        case .unavailable(let reason):
            throw reason
        }
    }
    
    private static func newSession(useInstructions: Bool? = nil) -> LanguageModelSession {
        return .init(
            model: .default,
            instructions: (useInstructions ?? useInstructionsDefault) ? Self.instructions : nil
        )
    }
    
    public var isResponding: Bool { session.isResponding }
    
    public func taskResponse(to: String) {
        let input = to.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        
        cancelGeneration()
        
        chatHistory.append(.init(isUser: true, text: input))
        
        let response = Message(isUser: false, text: "")
        chatHistory.append(response)
        
        generationTask = Task {
            defer {
                Task { @MainActor in
                    generationTask = nil
                }
            }
            
            do {
                let stream = session.streamResponse(to: input)
                
                for try await chunk in stream {
                    try Task.checkCancellation()
                    
                    await MainActor.run {
                        guard let index = chatHistory
                            .firstIndex(where: { $0.id == response.id }) else { return }
                        
                        chatHistory[index].text = chunk.content
                    }
                }
            } catch is CancellationError {
            } catch {
                await MainActor.run {
                    if let index: Int = chatHistory.firstIndex(where: { $0.id == response.id }),
                       chatHistory[index].text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        chatHistory.remove(at: index)
                    }
                    self.error = error
                }
            }
        }
    }
    
    public func clearChat(useInstructions: Bool? = nil) {
        cancelGeneration()
        chatHistory.removeAll()
        error = nil
        session = Self.newSession(useInstructions: useInstructions)
    }
    
    public func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
    }
    
}
