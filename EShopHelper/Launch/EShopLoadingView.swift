//
//  EShopLoadingView.swift
//  EShopHelper
//
//  Created by Jiang,Zhenhua on 2018/10/16.
//  Copyright © 2018 Daubert. All rights reserved.
//

import UIKit
import AVKit

class EShopLoadingView: UIView {
    
    private let animationLayer = CALayer()
    private lazy var audioPlayer: AVAudioPlayer? = {
        guard let filePath = Bundle.main.path(forResource: "eShop Load", ofType: "wav") else {
            return nil
        }
        let url = URL(fileURLWithPath: filePath)
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1 // 无限播放
        return player
    }()
    
    private let fixedHeight: CGFloat = 44
    private let duration: CFTimeInterval = 1
    private let label = UILabel()
    private var persistenceHelpers = [LayerPersistentHelper]()
    
    var fillColor = UIColor(r: 255, g: 156, b: 99) {
        didSet {
            animationLayer.sublayers?.forEach { $0.backgroundColor = fillColor.cgColor }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(r: 255, g: 120, b: 45)
        layer.addSublayer(animationLayer)
        
        label.font = UIFont.systemFont(ofSize: 27)
        label.text = "eShop"
        label.textColor = .white
        label.textAlignment = .center
        label.frame = .init(x: 0, y: 0, width: 79, height: 31.5)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        animationLayer.frame = .init(origin: .zero, size: rect.size)
        
        let count = Int(rect.height / fixedHeight)
        // frame发生变化，或者屏幕转向发生变化，则需要重绘
        if animationLayer.sublayers?.count ?? 0 != count ||
            animationLayer.frame.width != rect.width {
            animationLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            animationLayer.sublayers?.removeAll()
            persistenceHelpers.removeAll()
            
            for (i, y) in stride(from: 0, through: rect.height, by: fixedHeight).enumerated() {
                let bouncingLayer = CAShapeLayer()
                bouncingLayer.backgroundColor = fillColor.cgColor
                bouncingLayer.anchorPoint = .zero // 默认是在中间，这里需要设置为0.0
                bouncingLayer.frame = .init(x: 0, y: y, width: rect.width, height: fixedHeight)
                
                let animation = CABasicAnimation(keyPath: "bounds.size.width")
                animation.duration = duration
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fromValue = 0
                animation.toValue = rect.width
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * (duration / Double(count))
                animation.fillMode = kCAFillModeBackwards
                animation.repeatCount = .greatestFiniteMagnitude
                animation.autoreverses = true
                animation.delegate = self
                
                bouncingLayer.add(animation, forKey: "bouncing_\(i)")
                
                animationLayer.addSublayer(bouncingLayer)
                // 添加前后台切换工具类
                let helper = LayerPersistentHelper(with: bouncingLayer)
                persistenceHelpers.append(helper)
            }
        }
        
        label.frame.origin.x = rect.width - label.frame.width - 20
        label.frame.origin.y = rect.height - label.frame.height - 20
    }
    
    deinit {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension EShopLoadingView: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        if audioPlayer?.isPlaying == false {
            audioPlayer?.play()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
        }
    }
}
