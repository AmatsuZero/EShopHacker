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
    
    func slice(_ start: Int, _ length: Int? = nil) -> String {
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
}
