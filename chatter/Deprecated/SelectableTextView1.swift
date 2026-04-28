//
//  SelectableTextView.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import SwiftUI
import UIKit


struct SelectableText1: UIViewRepresentable {
    let text: String

    private var uiFont: UIFont = .preferredFont(forTextStyle: .body)
    private var uiColor: UIColor = .label
    private var uiAlignment: NSTextAlignment = .natural
    private var maxLines: Int? = nil

    init(_ text: String, color: UIColor = .label, alignment: TextAlignment = .leading) {
        self.text = text
        self.uiColor = color
        self.uiAlignment = switch alignment {
        case .leading: .left
        case .center: .center
        case .trailing: .right
        }
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0

        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = uiFont
        uiView.textColor = uiColor
        uiView.textAlignment = uiAlignment
        uiView.textContainer.maximumNumberOfLines = maxLines ?? 0
        uiView.textContainer.lineBreakMode = maxLines == nil ? .byWordWrapping : .byTruncatingTail
    }

    func sizeThatFits(_ proposal: ProposedViewSize,
                      uiView: UITextView,
                      context: Context) -> CGSize? {

        let maxAllowedWidth = proposal.width ?? CGFloat.greatestFiniteMagnitude

        let singleLineSize = uiView.sizeThatFits(
            CGSize(width: CGFloat.greatestFiniteMagnitude,
                   height: CGFloat.greatestFiniteMagnitude)
        )

        let targetWidth = min(ceil(singleLineSize.width), maxAllowedWidth)

        let fittedSize = uiView.sizeThatFits(
            CGSize(width: targetWidth,
                   height: CGFloat.greatestFiniteMagnitude)
        )

        return CGSize(width: ceil(targetWidth),
                      height: ceil(fittedSize.height))
    }

    func font(_ font: UIFont) -> Self {
        var copy = self
        copy.uiFont = font
        return copy
    }

    func foregroundColor(_ color: UIColor) -> Self {
        var copy = self
        copy.uiColor = color
        return copy
    }

    func multilineTextAlignment(_ alignment: TextAlignment) -> Self {
        var copy = self
        switch alignment {
        case .leading: copy.uiAlignment = .left
        case .center: copy.uiAlignment = .center
        case .trailing: copy.uiAlignment = .right
        }
        return copy
    }

    func lineLimit(_ limit: Int?) -> Self {
        var copy = self
        copy.maxLines = limit
        return copy
    }
}
