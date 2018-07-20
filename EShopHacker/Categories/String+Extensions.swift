//
//  String+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/20.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
}
