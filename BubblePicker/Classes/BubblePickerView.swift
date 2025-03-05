//
//  BubblePickerView.swift
//  Pods
//
//  Created by gaoyu on 2025/2/7.
//

import SpriteKit

public class BubblePickerView: SKView {
    
    @objc
    public lazy var bubbleScene: BubblePickerScene = { [unowned self] in
        let scene = BubblePickerScene(size: self.bounds.size)
        scene.backgroundColor = .clear
        self.presentScene(scene)
        return scene
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bubbleScene.size = bounds.size
    }
}
