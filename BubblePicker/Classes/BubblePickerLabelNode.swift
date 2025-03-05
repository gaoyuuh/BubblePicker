//
//  BubblePickerLabelNode.swift
//  OGKitSon
//
//  Created by gaoyu on 2025/2/7.
//

import SpriteKit

@objcMembers public class BubblePickerLabelNode: SKNode {
    open var text: String? { didSet { update() } }
    
    open var fontName: String = "PingFangSC-Regular" { didSet { update() } }
    open var fontSize: CGFloat = 14 { didSet { update() } }
    open var fontColor: UIColor = .black { didSet { update() } }
    
    open var separator: String? { didSet { update() } }
    
    open var lineHeight: CGFloat? { didSet { update() } }
    
    open var width: CGFloat! { didSet { update() } }
    
    func update() {
        self.removeAllChildren()
        
        guard let text = text else { return }
        
        var stack = Stack<String>()
        var sizingLabel = makeSizingLabel()
        let words = separator.map { text.components(separatedBy: $0) } ?? text.map { String($0) }
        for (index, word) in words.enumerated() {
            sizingLabel.text += word
            if sizingLabel.frame.width > width, index > 0 {
                stack.add(toStack: word)
                sizingLabel = makeSizingLabel()
            } else {
                stack.add(toCurrent: word)
            }
        }
        
        let lines = stack.values.map { $0.joined(separator: separator ?? "") }
        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: fontName)
            label.numberOfLines = 0
            label.fontSize = fontSize
            label.fontColor = fontColor
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            let y = (CGFloat(index) - (CGFloat(lines.count) / 2) + 0.5) * -(lineHeight ?? fontSize)
            label.position = CGPoint(x: 0, y: y)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attr = NSMutableAttributedString(string: line, attributes: [
                .font: UIFont(name: fontName, size: fontSize) as Any,
                .foregroundColor: fontColor,
                .paragraphStyle: paragraphStyle
            ])
            label.attributedText = attr
            
            self.addChild(label)
        }
    }
    
    private func makeSizingLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontName)
        label.fontSize = fontSize
        return label
    }
}

private struct Stack<U> {
    typealias T = (stack: [[U]], current: [U])
    private var value: T
    var values: [[U]] {
        return value.stack + [value.current]
    }
    init() {
        self.value = (stack: [], current: [])
    }
    mutating func add(toStack element: U) {
        self.value = (stack: value.stack + [value.current], current: [element])
    }
    mutating func add(toCurrent element: U) {
        self.value = (stack: value.stack, current: value.current + [element])
    }
}

private func +=(lhs: inout String?, rhs: String) {
    lhs = (lhs ?? "") + rhs
}
