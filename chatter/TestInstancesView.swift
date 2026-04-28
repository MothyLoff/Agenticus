//
//  TestInstancesView.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

internal let languageModelController_test = try! LanguageModelController()

internal extension ContentView {
    static func testInit() -> Self {
        return Self.init(
            languageModelController: languageModelController_test,
        )
    }
}
