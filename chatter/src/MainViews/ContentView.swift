//
//  ContentView.swift
//  chatter
//
//  Created by Тимофей Фролов on 24.04.2026.
//

import SwiftUI


struct ContentView: View {
    
    @State var languageModelController: LanguageModelController
    
    var body: some View {
        ChatView(languageModelController: languageModelController)
    }
}


#Preview {
    ContentView.testInit()
}
