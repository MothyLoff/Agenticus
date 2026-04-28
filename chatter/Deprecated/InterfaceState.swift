//
//  UserInterface.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import Combine
import SwiftUI


final class InterfaceState: ObservableObject {
    
    @Published var textField: String = ""
    @Published var inputFocused: Bool = false
    @Published var scrollPosition = ScrollPosition(edge: .bottom)
    
    @Published var isAtBottom: Bool = true
    //@Published var showScrollDownButton = false
    
    public func stayAtBottom() {
        if isAtBottom {
            scrollToBottom(animated: false)
        }
    }
    
    public func scrollToBottom(animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                scrollPosition.scrollTo(edge: .bottom)
            }
        } else {
            scrollPosition.scrollTo(edge: .bottom)
        }
        isAtBottom = true
    }
    
}
