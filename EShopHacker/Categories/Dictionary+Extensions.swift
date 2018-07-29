//
//  Dictionart+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/29.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation

infix operator +=
func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}
