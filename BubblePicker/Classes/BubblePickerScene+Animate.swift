//
//  BubblePickerScene+Animate.swift
//  SpriteBubblePicker
//
//  Created by gaoyu on 2025/3/6.
//

import Foundation
import SpriteKit


extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}


// MARK: - 添加动画

extension BubblePickerScene {
    
    /// 首次添加数据
    public func showToCenter(nodes: [BubblePickerNode]) {
        guard nodes.count > 0 else { return }
        
        for (index, node) in nodes.enumerated() {
            // 8个球为一组，大致相同x。减少重复位置碰撞问题
            var x = -(CGFloat(index / 8 + 1) * node.frame.width )
            if index % 2 == 0 {
                x = frame.width + CGFloat(index / 8 + 1) * node.frame.width
            }
            let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
            node.position = CGPoint(x: x, y: y)
            
            self.addNode(node, isFirst: true)
        }
    }
    
}


// MARK: - 插入动画

extension BubblePickerScene {
        
    public func insert(nodes: [BubblePickerNode], atNode: BubblePickerNode) {
        guard nodes.count > 0 else { return }
        
        self.resetNodeBody()
        self.enableMagneticField(false)
        atNode.physicsBody?.isDynamic = false
        atNode.subNodes.removeAll()
        
        let nearPositions = self.getNearbyNodes(atNode: atNode)
        let lastIndex = nodes.count - 1
        
        for (index, item) in nodes.enumerated() {
            var nearNode: BubblePickerNode? = nil
            // 使 insertNode 与 nearNode size 一致，避免碰撞挤压
            if index < nearPositions.count {
                nearNode = nearPositions[index]
                if let nearNode {
                    item.update(radius: nearNode.radius)
                }
            }
            
            item.setScale(0)
            item.physicsBody?.isDynamic = false
            item.zPosition = CGFloat(-10 - index)
            item.position = atNode.position
            self.addNode(item)
            atNode.subNodes.append(item)
            
            
            // 位移动画
            var moveAction = SKAction.moveBy(x: (index % 2) == 0 ? item.radius : -item.radius, y: 0, duration: 0.4)
            if let nearNode {
                moveAction = SKAction.move(to: nearNode.position, duration: 0.4)
                
                // nearNode 位移动画
                animateNearNode(nearNode, insertNode: item, node: atNode)
            }
            
            // 缩放动画
            let waitAction = SKAction.wait(forDuration: 0.1)
            let scale = SKAction.scale(to: 1, duration: 0.4)
            let scaleAction = SKAction.sequence([waitAction, scale])
            
            // 执行插入 node 动画
            item.run(.group([ moveAction, scaleAction ])) {
                // 恢复 insertNode 初始值
                item.physicsBody?.isDynamic = true
                item.zPosition = 0
                nearNode?.physicsBody?.density = 1
                if index == lastIndex {
                    atNode.physicsBody?.isDynamic = true
                }
            }
        }
    }
    
    /// nearNode 位移动画
    private func animateNearNode(_ nearNode: BubblePickerNode, insertNode: BubblePickerNode, node: BubblePickerNode) {
        var moveX = nearNode.position.x + insertNode.radius + nearNode.radius
        if nearNode.position.x < node.position.x {
            moveX = nearNode.position.x - insertNode.radius - nearNode.radius
        }
        let act = SKAction.move(to: CGPoint(x: moveX, y: nearNode.position.y), duration: 0.4)
        act.timingMode = .easeOut
        nearNode.run(act)
        nearNode.physicsBody?.density = 100
    }
    
}


// MARK: - 删除动画

extension BubblePickerScene {
    
    /// 删除
    /// nodes: 要删除的 node 数组
    /// atNode: 如果有，则以 atNode 为中心删除
    public func remove(nodes: [BubblePickerNode], atNode: BubblePickerNode? = nil) {
        guard nodes.count > 0 else { return }
        
        self.resetNodeBody()
        self.enableMagneticField(true)
        
        if let atNode {
            atNode.physicsBody?.isDynamic = false
            atNode.subNodes.removeAll()
        }
    
        for (_, removeNode) in nodes.enumerated() {
            removeNode.removeFromParent()
        }
    }
    
}
