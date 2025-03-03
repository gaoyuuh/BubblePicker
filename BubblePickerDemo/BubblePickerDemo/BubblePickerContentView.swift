//
//  BubblePickerContentView.swift
//  BubblePickerDemo
//
//  Created by gaoyu on 2025/2/28.
//

import UIKit
import SpriteKit
import BubblePicker

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

extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
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
        case size152 = 152
        
        static var all: [NodeSize] {
            [.size152]
        }
        
        var fontSize: CGFloat {
            switch self {
            case .size152: return 18
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
        
        for (index, content) in array.enumerated() {
            let node = self.getNode(title: content)
            self.bubbleScene.addNode(node, isFirst: true)
            
            // 8个球为一组，大致相同x。减少重复位置碰撞问题
            var x = -(CGFloat(index / 8 + 1) * node.frame.width )
            if index % 2 == 0 {
                x = frame.width + CGFloat(index / 8 + 1) * node.frame.width
            }
            let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
            node.position = CGPoint(x: x, y: y)
        }
    }
    
    /// 插入
    public func insertFromArray(_ array: [String], node: BubblePickerNode) {
        guard array.count > 0 else { return }
        
        self.bubbleScene.resetNodeBody()
        self.bubbleScene.enableMagneticField(false)
        node.physicsBody?.isDynamic = false
        let nearPositions = self.bubbleScene.getNearbyNodes(atNode: node)
        node.subNodes.removeAll()

        for (index, item) in array.enumerated() {
            
            var nearNode: BubblePickerNode? = nil
            var size: NodeSize? = nil
            if index < nearPositions.count {
                nearNode = nearPositions[index]
                if let nearNode {
                    size = NodeSize(rawValue: nearNode.radius * 2)
                }
            }
            
            let insertNode = self.getNode(title: item, size: size)
            insertNode.setScale(0)
            insertNode.physicsBody?.isDynamic = false
            insertNode.zPosition = CGFloat(-10-index)
            insertNode.position = node.position
            self.bubbleScene.addNode(insertNode)
            node.subNodes.append(insertNode)
            
            // 位移动画
            var moveAction = SKAction.moveBy(x: (index % 2) == 0 ? insertNode.radius : -insertNode.radius, y: 0, duration: 0.4)
            if let nearNode {
                moveAction = SKAction.move(to: nearNode.position, duration: 0.4)
                
                // nearNode 位移动画
                var moveX = nearNode.position.x + insertNode.radius + nearNode.radius
                if nearNode.position.x < node.position.x {
                    moveX = nearNode.position.x - insertNode.radius - nearNode.radius
                }
                let act = SKAction.move(to: CGPoint(x: moveX, y: nearNode.position.y), duration: 0.4)
                act.timingMode = .easeOut
                nearNode.run(act)
                nearNode.physicsBody?.density = 100
            }
            
            // 缩放动画
            let waitAction = SKAction.wait(forDuration: 0.1)
            let scale1 = SKAction.scale(to: 1.1, duration: 0.4)
            let scale2 = SKAction.scale(to: 1, duration: 0.15)
            let scaleAction = SKAction.sequence([waitAction, scale1, scale2])
            
            insertNode.run(.group([ moveAction, scaleAction ])) {
                insertNode.physicsBody?.isDynamic = true
                insertNode.zPosition = 0
                nearNode?.physicsBody?.density = 1
                if index == array.count - 1 {
                    node.physicsBody?.isDynamic = true
                }
            }
        }
    }

    
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

extension BubblePickerContentView: BubblePickerDelegate {
    
    func didSelect(_ scene: BubblePickerScene, node: BubblePickerNode) {
        self.selectNodeBlock?(node)
        node.selectedAnimation()
    }
    
    func didDeselect(_ scene: BubblePickerScene, node: BubblePickerNode) {
        self.deSelectNodeBlock?(node)

        if node.subNodes.count <= 0 {
            return
        }
        
        self.bubbleScene.resetNodeBody()
        self.bubbleScene.enableMagneticField(true)
        node.physicsBody?.isDynamic = false
        
        let removeNodes = node.subNodes.filter { !$0.isSelected }
        for (_, removeNode) in removeNodes.enumerated() {
            removeNode.removeFromParent()
        }
        node.subNodes.removeAll()
    }
    
}
