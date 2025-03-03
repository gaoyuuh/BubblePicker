//
//  BubblePickerScene.swift
//  OGKitSon
//
//  Created by gaoyu on 2025/2/7.
//

import SpriteKit
import SwiftLogger

@objc public protocol BubblePickerDelegate: AnyObject {
    func didSelect(_ scene: BubblePickerScene, node: BubblePickerNode)
    func didDeselect(_ scene: BubblePickerScene, node: BubblePickerNode)
}

public class BubblePickerScene: SKScene {
    
    public weak var bubblePickerDelegate: BubblePickerDelegate?

    private lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.contentNode.addChild(field)
        return field
    }()
    
    private lazy var rootNode = {
        let node = SKSpriteNode()
        self.addChild(node)
        return node
    }()
    
    private lazy var contentNode = {
        let node = SKSpriteNode()
        self.rootNode.addChild(node)
        return node
    }()
    
    private var contentFrame: CGRect = .zero
    
    private var paddingHorizontal: CGFloat = 50
    
    private var isDragging: Bool = false
    
    private var lastTouchPosition: CGPoint?
    
    private var velocity: CGFloat = 0  // 记录速度
    
    /// 物理世界最大宽度
    private var physicsBodyMaxWidth: CGFloat = 0
    
    private var firstAdd: Bool = false
    
    override public var size: CGSize {
        didSet {
            configure()
        }
    }
    
    override public init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    public override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    /// SKView 渲染前最后一步
    public override func didFinishUpdate() {
        let newFrame = self.contentNode.calculateAccumulatedFrame()
        // width 相差 10 以内，不需要更新
        let widthDifferenceThreshold: CGFloat = 10
        if abs(newFrame.origin.x - self.contentFrame.origin.x) > widthDifferenceThreshold ||
            abs(newFrame.width - self.contentFrame.width) > widthDifferenceThreshold {
            self.contentFrame = newFrame
            SwiftLogger.debug("updateFrame: \(newFrame)")
            
            // 扩容
            if self.contentFrame.width > physicsBodyMaxWidth * 0.75 {
                updatePhysicsBody()
            }
            
            // 更新磁力场
            updateMagneticField()
        }
    }
        
    private func commonInit() {
        backgroundColor = .white
        configure()
    }
    
    private func configure() {
        self.contentFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.speed = 1.5
        updatePhysicsBody()
        updateMagneticField()
        enableMagneticField(true)
    }
    
    private func updatePhysicsBody() {
        self.physicsBodyMaxWidth = self.contentFrame.width * 10
        physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = physicsBodyMaxWidth
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
    }
    
    private func updateMagneticField() {
        let ratio: Float = 1.5
        if abs(self.contentFrame.width - CGFloat(self.magneticField.minimumRadius / ratio)) < 10 {
            return
        }
        let fieldWidth = self.contentFrame.width * CGFloat(ratio)
        self.magneticField.region = SKRegion(size: CGSizeMake(fieldWidth, size.height * 2))
        self.magneticField.minimumRadius = Float(fieldWidth)
        self.magneticField.strength = Float(fieldWidth / 2)
        self.magneticField.position = CGPointMake(self.size.width / 2, self.size.height / 2)
    }
    
    public func enableMagneticField(_ enable: Bool) {
        self.magneticField.isEnabled = enable
    }
        
    public func addNode(_ node: SKNode, isFirst: Bool = false) {
        self.firstAdd = isFirst
        self.contentNode.addChild(node)
    }
    
    public func resetNodeBody() {
        for node in self.contentNode.children {
            if let node = node as? BubblePickerNode {
                node.physicsBody?.isDynamic = true
                node.physicsBody?.density = 1
                node.zPosition = 0
            }
        }
    }
    
    public func allChildNodes() -> [BubblePickerNode] {
        var temp = [BubblePickerNode]()
        for node in self.contentNode.children {
            if let node = node as? BubblePickerNode {
                temp.append(node)
            }
        }
        return temp
    }

    /// 获取 node 节点周围节点
    public func getNearbyNodes(atNode: BubblePickerNode) -> [BubblePickerNode] {
        func _nearbyNodes(atNode: SKNode, radius: CGFloat) -> [SKNode] {
            let nearbyNodes = self.contentNode.children.filter { otherNode in
                guard otherNode != atNode else { return false }
                let distance = otherNode.position.distance(from: atNode.position)
                return distance <= radius
            }
            return nearbyNodes.sorted { (nodeA, nodeB) -> Bool in
                let distanceA = nodeA.position.distance(from: atNode.position)
                let distanceB = nodeB.position.distance(from: atNode.position)
                return distanceA < distanceB
            }
        }
        
        // 获取周围节点
        let nodes = _nearbyNodes(atNode: atNode, radius: atNode.radius * 2 * 2)
        var temp = [BubblePickerNode]()
        for node in nodes {
            if let shapeNode = node as? BubblePickerNode {
                temp.append(shapeNode)
            }
        }
        return temp
    }
}


extension BubblePickerScene {
    
    
    // MARK: UITouch
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let node = node(at: location) else { return }
        
        if node.isSelected {
            node.isSelected = false
            bubblePickerDelegate?.didDeselect(self, node: node)
        } else {
            node.isSelected = true
            bubblePickerDelegate?.didSelect(self, node: node)
        }
    }
    
    
    // MARK: - UIPanGestureRecognizer
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: recognizer.view)
        let sceneLocation = convertPoint(fromView: location)
        
        if recognizer.state == .began {
            lastTouchPosition = sceneLocation
            isDragging = true
        } else if recognizer.state == .changed {
            if let lastPosition = lastTouchPosition {
                let deltaX = sceneLocation.x - lastPosition.x
                var newPositionX = rootNode.position.x + deltaX
                
                // 左边界检查
                if newPositionX >= minX() {
                    newPositionX = minX()
                }
                // 右边界检查
                if newPositionX <= maxX() {
                    newPositionX = maxX()
                }
                
                rootNode.position.x = newPositionX
                
                SwiftLogger.debug("change: \(rootNode.position.x)")
                
                velocity = deltaX  // 记录当前的速度
            }
            lastTouchPosition = sceneLocation
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            isDragging = false
            startDeceleration()  // 手势结束后启动减速
        }
    }
    
    private func startDeceleration() {
        let decelerationRate: CGFloat = 0.98  // 控制减速效果的快慢
        let minSpeed: CGFloat = 0.5  // 最小速度阈值
        let duration = 1 / 60.0
        
        SwiftLogger.debug(velocity)
        
        if isDragging || abs(velocity) < minSpeed {
            return  // 如果速度很小则停止
        }
        
        // 获取当前节点的位置并进行边界检查
        var newPositionX = self.rootNode.position.x + velocity
        // 左边界检查
        if newPositionX >= minX() {
            newPositionX = minX()
            self.velocity = 0
        }
        // 右边界检查
        if newPositionX <= maxX() {
            newPositionX = maxX()
            self.velocity = 0
        }
        
        SwiftLogger.debug("end: \(newPositionX)")
        
        // 应用修正后的位置并执行动画
        let correctedMoveAction = SKAction.moveTo(x: newPositionX, duration: duration)
        self.rootNode.run(correctedMoveAction) {
            // 应用减速
            self.velocity *= decelerationRate
            // 持续调用该方法直到速度减小到一定程度
            if !self.isDragging && abs(self.velocity) > minSpeed {
                self.startDeceleration()
            }
        }
    }
    
    private func minX() -> CGFloat {
        return -self.contentFrame.origin.x + paddingHorizontal
    }
    
    private func maxX() -> CGFloat {
        let maxX = CGRectGetMaxX(self.contentFrame) - self.size.width
        return -maxX - paddingHorizontal
    }
    
    private func node(at point: CGPoint) -> BubblePickerNode? {
        return nodes(at: point).compactMap { $0 as? BubblePickerNode }.filter { $0.path!.contains(convert(point, to: $0)) }.first
    }
}


extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

