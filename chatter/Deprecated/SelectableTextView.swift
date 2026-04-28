//
//  SelectableTextView.swift
//  chatter
//
//  Created by Тимофей Фролов on 23.04.2026.
//

import SwiftUI
import UIKit
import Foundation


struct SelectableText: UIViewRepresentable {
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
        view.adjustsFontForContentSizeCategory = true

        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.textAlignment = uiAlignment
        uiView.textContainer.maximumNumberOfLines = maxLines ?? 0
        uiView.textContainer.lineBreakMode = maxLines == nil ? .byWordWrapping : .byTruncatingTail
        uiView.linkTextAttributes = [.foregroundColor: uiColor]
        uiView.attributedText = makeAttributedText()
    }

    func sizeThatFits(_ proposal: ProposedViewSize,
                      uiView: UITextView,
                      context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite, width > 0 else {
            return nil
        }

        let size = uiView.sizeThatFits(
            CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        )

        return CGSize(width: width, height: ceil(size.height))
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

    private func makeAttributedText() -> NSAttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full,
            failurePolicy: .returnPartiallyParsedIfPossible
        )

        guard var attributed = try? AttributedString(markdown: text, options: options) else {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = uiAlignment
            paragraph.lineBreakMode = maxLines == nil ? .byWordWrapping : .byTruncatingTail

            return NSAttributedString(
                string: text,
                attributes: [
                    .font: uiFont,
                    .foregroundColor: uiColor,
                    .paragraphStyle: paragraph
                ]
            )
        }

        for run in attributed.runs {
            let range = run.range
            let inlineIntent = run.inlinePresentationIntent
            let presentationIntent = run.presentationIntent

            attributed[range].font = Font(fontForRun(
                inlineIntent: inlineIntent,
                presentationIntent: presentationIntent
            ))
            attributed[range].foregroundColor = Color(uiColor)
        }

        let mutable = NSMutableAttributedString(attributed)
        let fullRange = NSRange(location: 0, length: mutable.length)

        mutable.enumerateAttribute(.paragraphStyle, in: fullRange) { value, range, _ in
            let paragraph = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            paragraph.alignment = uiAlignment
            paragraph.lineBreakMode = maxLines == nil ? .byWordWrapping : .byTruncatingTail
            paragraph.paragraphSpacing = max(paragraph.paragraphSpacing, 6)
            paragraph.lineSpacing = max(paragraph.lineSpacing, 2)
            mutable.addAttribute(.paragraphStyle, value: paragraph, range: range)
        }

        if mutable.length > 0, mutable.attribute(.paragraphStyle, at: 0, effectiveRange: nil) == nil {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = uiAlignment
            paragraph.lineBreakMode = maxLines == nil ? .byWordWrapping : .byTruncatingTail
            paragraph.paragraphSpacing = 6
            paragraph.lineSpacing = 2
            mutable.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        }

        return mutable
    }

    private func fontForRun(
        inlineIntent: InlinePresentationIntent?,
        presentationIntent: PresentationIntent?
    ) -> UIFont {
        var descriptor = uiFont.fontDescriptor
        var size = uiFont.pointSize

        if let presentationIntent {
            for component in presentationIntent.components {
                switch component.kind {
                case .header(let level):
                    switch level {
                    case 1: size = uiFont.pointSize * 2.0
                    case 2: size = uiFont.pointSize * 1.7
                    case 3: size = uiFont.pointSize * 1.45
                    case 4: size = uiFont.pointSize * 1.25
                    default: size = uiFont.pointSize * 1.1
                    }
                    descriptor = descriptor.withSymbolicTraits([.traitBold]) ?? descriptor
                case .codeBlock:
                    descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                        .withDesign(.monospaced) ?? descriptor
                default:
                    break
                }
            }
        }

        if let inlineIntent {
            if inlineIntent.contains(.code) {
                descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                    .withDesign(.monospaced) ?? descriptor
            }

            var traits = descriptor.symbolicTraits
            if inlineIntent.contains(.stronglyEmphasized) {
                traits.insert(.traitBold)
            }
            if inlineIntent.contains(.emphasized) {
                traits.insert(.traitItalic)
            }
            descriptor = descriptor.withSymbolicTraits(traits) ?? descriptor
        }

        return UIFont(descriptor: descriptor, size: size)
    }
}
