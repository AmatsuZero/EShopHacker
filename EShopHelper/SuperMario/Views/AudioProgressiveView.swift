//
//  AudioProgressiveView.swift
//  EShopHelper
//
//  Created by Jiang,Zhenhua on 2018/10/16.
//  Copyright © 2018 Daubert. All rights reserved.
//

import UIKit

class AudioProgressiveView: UIView {

    var percentage: CGFloat = 0 {
        didSet {
            // 在修改百分比的时候，修改彩色遮罩的大小
            maskLayer.strokeEnd = percentage
        }
    }
    
    private let drawMargin: CGFloat = 4
    private let drawLineWidth: CGFloat = 8
    
    /// 灰色路径
    private let shapeLayer = CAShapeLayer()
    /// 背景黄色
    private let backColorLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    
    /// 灰条颜色
    var barColor = UIColor.gray {
        didSet {
            shapeLayer.strokeColor = barColor.cgColor
        }
    }
    
    /// 填充颜色
    var fillColor = UIColor.yellow {
        didSet {
            backColorLayer.strokeColor = fillColor.cgColor
            maskLayer.strokeColor = fillColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.lineWidth = drawLineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor // 填充色为透明
        shapeLayer.lineCap = kCALineCapRound // 设置线为圆角
        shapeLayer.strokeColor = barColor.cgColor // 路径颜色颜色
        
        backColorLayer.lineWidth = drawLineWidth
        backColorLayer.fillColor = UIColor.clear.cgColor
        backColorLayer.lineCap = kCALineCapRound
        backColorLayer.strokeColor = fillColor.cgColor
        
        maskLayer.strokeColor = fillColor.cgColor
        
        backgroundColor = .black
        layer.addSublayer(shapeLayer)
        layer.addSublayer(backColorLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAnimation(percentage: CGFloat) {
        let startPercentage = self.percentage
        self.percentage = percentage
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = startPercentage
        pathAnimation.toValue = percentage
        pathAnimation.autoreverses = false
        pathAnimation.delegate = self
        maskLayer.add(pathAnimation, forKey: "strokeEndAnimation")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 灰色路径
        let path = UIBezierPath()
        var x: CGFloat = 0
        while x + drawLineWidth <= rect.width {
            let random = CGFloat.random(in: 0..<51) + 5.0
            path.move(to: .init(x: x - drawLineWidth/2, y: random))
            path.addLine(to: .init(x: x - drawLineWidth/2, y: rect.height - random))
            x += drawLineWidth
            x += drawMargin
        }
        shapeLayer.path = path.cgPath
        backColorLayer.path = path.cgPath
       
        // 设置背景layer
        let maskPath = UIBezierPath()
        maskPath.move(to: .init(x: 0, y: rect.height / 2))
        maskPath.addLine(to: .init(x: rect.width, y: rect.height / 2))
        maskLayer.frame = .init(x: 0, y: 0, width: rect.width, height: rect.height)
        maskLayer.lineWidth = rect.width
        maskLayer.path = maskPath.cgPath
        backColorLayer.mask = maskLayer
    }
}

extension AudioProgressiveView: CAAnimationDelegate {
    
}
