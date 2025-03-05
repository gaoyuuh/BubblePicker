//
//  BubblePickerNode.swift
//  OGKitSon
//
//  Created by gaoyu on 2025/2/7.
//

import SpriteKit

@objcMembers public class BubblePickerNode: SKShapeNode {

    public lazy var label: BubblePickerLabelNode = { [unowned self] in
        let label = BubblePickerLabelNode()
        label.fontName = Defaults.fontName
        label.fontSize = Defaults.fontSize
        label.fontColor = Defaults.fontColor
        label.width = self.frame.width - 20
        label.separator = " "
        addChild(label)
        return label
    }()
    
    /// 绑定数据
    open var bindData: Any?
    
    /// 关联子 node
    open lazy var subNodes = [BubblePickerNode]()
    
    /**
     The text displayed by the node.
     */
    open var text: String? {
        get { return label.text }
        set {
            label.text = newValue
            resize()
        }
    }
    
    /**
     The image displayed by the node.
     */
    open var image: UIImage? {
        didSet {
            texture = image.map { SKTexture(image: $0) }
            fillTexture = texture
        }
    }
    
    /**
     The image displayed by the node.
     */
    open var selectImage: UIImage? {
        didSet {
            selectTexture = selectImage.map { SKTexture(image: $0) }
        }
    }
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor = Defaults.color {
        didSet {
            self.fillColor = color
        }
    }
    
    open var texture: SKTexture?
    open var selectTexture: SKTexture?
    
    /**
     The selection state of the node.
     */
    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                
            } else {
                deselectedAnimation()
            }
        }
    }
    
    /**
     Controls whether the node should auto resize to fit its content
     */
    open var scaleToFitContent: Bool = Defaults.scaleToFitContent {
        didSet {
            resize()
        }
    }
    
    /**
     Additional padding to be applied on resize
     */
    open var padding: CGFloat = Defaults.padding {
        didSet {
            resize()
        }
    }
    
    /**
     The duration of the selected/deselected animations
     */
    open var animationDuration: TimeInterval = 0.2
  
    /**
     The name of the label's font
    */
    open var fontName: String {
      get { label.fontName }
      set {
        label.fontName = newValue
        resize()
      }
    }
    
    /**
     The size of the label's font
    */
    open var fontSize: CGFloat {
      get { label.fontSize }
      set {
        label.fontSize = newValue
        resize()
      }
    }
    
    /**
     The color of the label's font
    */
    open var fontColor: UIColor {
      get { label.fontColor }
      set { label.fontColor = newValue }
    }
    
    /**
     The margin scale of the node
     */
    open var marginScale: CGFloat = Defaults.marginScale {
      didSet {
        guard let path = path else { return }
        regeneratePhysicsBody(withPath: path)
      }
    }
    
    open private(set) var radius: CGFloat = 50
    
    /**
     Set of default values
     */
    struct Defaults {
        static let fontName = "PingFangSC-Regular"
        static let fontColor = UIColor.white
        static let fontSize = CGFloat(14)
        static let color = UIColor.clear
        static let marginScale = CGFloat(0.9)
        static let scaleToFitContent = false // backwards compatability
        static let padding = CGFloat(20)
    }
    
    /**
     Creates a node with a custom path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - path: The path of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public init(text: String? = nil, image: UIImage? = nil, color: UIColor, path: CGPath, marginScale: CGFloat = 1.01) {
        super.init()
        self.path = path
        regeneratePhysicsBody(withPath: path)
        self.color = color
        self.strokeColor = .clear
        _ = self.text
        configure(text: text, image: image, color: color)
    }
    
    /**
     Creates a node with a circular path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - radius: The radius of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public convenience init(text: String? = nil, image: UIImage? = nil, color: UIColor, radius: CGFloat, marginScale: CGFloat = 1.01) {
        let path = SKShapeNode(circleOfRadius: radius).path!
        self.init(text: text, image: image, color: color, path: path, marginScale: marginScale)
        self.radius = radius
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(text: String?, image: UIImage?, color: UIColor) {
        self.text = text
        self.image = image
        self.color = color
    }
    
    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }
    
    /**
     Resizes the node to fit its current content
     */
    public func resize() {
        guard scaleToFitContent, let text = text, let font = UIFont(name: fontName, size: fontSize) else { return }
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        let radius = size.width / 2 + CGFloat(padding)
        update(radius: radius, withLabelWidth: size.width)
    }
    
    /**
     Updates the radius of the node and sets the label width to a given width or the radius
     
      - Parameters:
        - radius: The new radius
        - withLabelWidth: A custom width for the text label
     */
    public func update(radius: CGFloat, withLabelWidth width: CGFloat? = nil) {
        guard let path = SKShapeNode(circleOfRadius: radius).path else { return }
        self.path = path
        self.label.width = width ?? radius
        self.radius = radius
        regeneratePhysicsBody(withPath: path)
    }
    
    /**
     Regenerates the physics body with a given path after the path has changed .i.e. after resize
     */
    public func regeneratePhysicsBody(withPath path: CGPath) {
        self.physicsBody = {
          var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
          let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
          body.allowsRotation = false
          body.friction = 0
          body.linearDamping = 3
          return body
        }()
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        let scale1Action = SKAction.scale(to: 0.9, duration: animationDuration)
        let scale2Action = SKAction.scale(to: 1, duration: animationDuration)
        run(.sequence([scale1Action, scale2Action]))

        if let texture = selectTexture {
            fillTexture = texture
        }
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        if let texture = texture {
            fillTexture = texture
        }
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.group([.fadeOut(withDuration: animationDuration), .scale(to: 0, duration: animationDuration)]), completion: completion)
    }
}
