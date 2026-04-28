//
//  chatterApp.swift
//  chatter
//
//  Created by Тимофей Фролов on 19.04.2026.
//

import SwiftUI


@main
struct chatterApp: App {
    
    let languageModelController: LanguageModelController?
    let modelAvailabilityError: Error?
    
    init() {
        do {
            languageModelController = try LanguageModelController()
            modelAvailabilityError = nil
        } catch {
            modelAvailabilityError = error
            languageModelController = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let languageModelController = languageModelController {
                ContentView(
                    languageModelController: languageModelController,
                )
            } else {
                ModelUnavailableView(modelAvailabilityError: modelAvailabilityError)
            }
        }
    }
}
