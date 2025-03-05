//
//  ViewController.swift
//  BubblePickerDemo
//
//  Created by gaoyu on 2025/2/28.
//

import UIKit
import SwiftLogger
import SpriteBubblePicker
import AVFoundation

class BackgroundVideoPlayer {
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    init(view: UIView, videoName: String = "tagNet-background", videoExtension: String = "mp4") {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        // 设置视频播放器的层级
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(playerLayer, at: 0)
        
        // 循环播放
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func startPlaying() {
        player.play()
    }
    
    @objc private func playerItemDidReachEnd() {
        player.seek(to: .zero)
        player.play()
    }
}

class ViewController: UIViewController {

    lazy var contentView: BubblePickerContentView = {
        let height = UIScreen.main.bounds.size.height / 4 * 3
        let view = BubblePickerContentView(frame: CGRectMake(0, (UIScreen.main.bounds.size.height - height) / 2, UIScreen.main.bounds.size.width, height))
        view.selectNodeBlock = { [weak self] node in
            SwiftLogger.debug("click \(node.text ?? "")")
            self?.selectAction(node: node)
        }
        view.deSelectNodeBlock = { node in
            SwiftLogger.debug("remove \(node.text ?? "")")
        }
        return view
    }()
    
    private var tags: [String] {
        ["有小众爱好", "比较害羞", "聪明", "喜欢户外", "可爱", "骑行", "稳定顾家", "平时爱运动", "有生活气", "吃吃喝喝", "有个性", "日常活动丰富", "有生活情调", "爱笑", "事业有成", "善良", "户外运动", "喜欢挑战", "温柔细心", "单纯", "身材好", "阳光", "情绪稳定", "同理心强", "摩托爱好者", "生活品质高", "乐观"]
    }
    
    private var backgroundVideoPlayer: BackgroundVideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加背景视频播放器
        backgroundVideoPlayer = BackgroundVideoPlayer(view: self.view)
        backgroundVideoPlayer.startPlaying()
        
        self.view.addSubview(self.contentView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.contentView.addWithArray(self.tags)
        }
    }
    
    func selectAction(node: BubblePickerNode) {
        let randomInsert = ["情绪稳定", "同理心强", "摩托爱好者", "生活品质高"]
        self.contentView.insertFromArray(randomInsert, node: node)
}
    }
