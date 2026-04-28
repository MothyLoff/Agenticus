//
//  ModelUnavailableView.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import SwiftUI


struct ModelUnavailableView: View {
    
    let modelAvailabilityError: Error?
    
    var body: some View {
        Text(modelAvailabilityError?.localizedDescription ?? "some error")
    }
}
