//
//  String+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/20.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

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
    
    func slice(_ start: Int, _ length: Int? = nil) -> String {
        guard start < self.count else {
            return self
        }
        let startIndex = self.index(self.startIndex, offsetBy: start+1)
        return length != nil
            ? String(self[startIndex...].prefix(length!))
            : String(self[startIndex...])
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    var cgFloatValue: CGFloat? {
        guard let n = NumberFormatter().number(from: self) else {
            return nil
        }
        return CGFloat(truncating: n)
    }
    
    var intValue: Int? {
        guard let n = NumberFormatter().number(from: self) else {
            return nil
        }
        return Int(truncating: n)
    }
}
