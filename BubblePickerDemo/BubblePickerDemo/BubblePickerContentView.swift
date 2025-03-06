//
//  BubblePickerContentView.swift
//  BubblePickerDemo
//
//  Created by gaoyu on 2025/2/28.
//

import UIKit
import SpriteBubblePicker

extension UIImage {
    static let defaultImage: [String] = ["unselect_bubble"]
    static let selectImage: [String] = ["select_blue", "select_green", "select_orange", "select_pink", "select_purple"]
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

class BubblePickerContentView: UIView {
    
    public var selectNodeBlock: ((_ node: BubblePickerNode) -> Void)?
    public var deSelectNodeBlock: ((_ node: BubblePickerNode) -> Void)?
    
    private lazy var contentView: BubblePickerView = {
        let view = BubblePickerView(frame: self.bounds)
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.bubbleScene.bubblePickerDelegate = self
#if DEBUG
        view.showsFPS = true
        view.showsDrawCount = true
        view.showsQuadCount = true
//        view.showsPhysics = true
//        view.showsFields = true
#endif
        return view
    }()
    
    private lazy var bubbleScene: BubblePickerScene = {
        return contentView.bubbleScene
    }()
    
    private enum NodeSize: CGFloat {
        case size142 = 142, size152 = 152, size162 = 162
        
        static var all: [NodeSize] {
            [.size142, .size152, .size162]
        }
        
        var fontSize: CGFloat {
            switch self {
            case .size142: return 16
            case .size152: return 18
            case .size162: return 18
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 首次添加
    public func addWithArray(_ array: [String]) {
        
        var nodes = [BubblePickerNode]()
        for (_, content) in array.enumerated() {
            let node = self.getNode(title: content)
            nodes.append(node)
        }
        self.bubbleScene.showToCenter(nodes: nodes)
    }
    
    /// 插入
    public func insertFromArray(_ array: [String], node: BubblePickerNode) {
        
        var nodes = [BubblePickerNode]()
        for (_, item) in array.enumerated() {
            let insertNode = self.getNode(title: item)
            nodes.append(insertNode)
        }
        self.bubbleScene.insert(nodes: nodes, atNode: node)
    }
    
}

extension BubblePickerContentView: BubblePickerDelegate {
    
    /// 选中标签
    func didSelect(_ scene: BubblePickerScene, node: BubblePickerNode) {
        self.selectNodeBlock?(node)
        node.selectedAnimation()
    }
    
    /// 取消选中标签
    func didDeselect(_ scene: BubblePickerScene, node: BubblePickerNode) {
        self.deSelectNodeBlock?(node)
        
        let removeNodes = node.subNodes.filter { !$0.isSelected }
        self.bubbleScene.remove(nodes: removeNodes, atNode: node)
    }
    
}


private extension BubblePickerContentView {
    
    private func getNode(title: String, size: NodeSize? = nil) -> BubblePickerNode {
        var nodeSize = getRandomNodeSize()
        if let size {
            nodeSize = size
        }
        let defaultImage = UIImage.defaultImage.randomItem()
        let selectImage = UIImage.selectImage.randomItem()
        var text = title
        if text.count >= 6 {
            let position = text.count - 4
            text.insert("\n", at: text.index(text.startIndex, offsetBy: position))
        }
        let node = BubblePickerNode(text: text, image: UIImage(named: defaultImage), color: .white, radius: nodeSize.rawValue * 0.5)
        node.marginScale = 0.9
        node.fontSize = nodeSize.fontSize
        node.selectImage = UIImage(named: selectImage)
        return node
    }
    
    private func getRandomNodeSize() -> NodeSize {
        return NodeSize.all.randomItem()
    }
    
}
