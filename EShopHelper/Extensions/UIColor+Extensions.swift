//
//  UIColor+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/10/16.
//  Copyright © 2018 Daubert. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
