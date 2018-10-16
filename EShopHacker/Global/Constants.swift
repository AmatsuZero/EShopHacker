//
//  Constants.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/19.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation

let GAME_CHECK_CODE_US = "70010000000185"
let GAME_CHECK_CODE_EU = "70010000000184"
let GAME_CHECK_CODE_JP = "70010000000039"

let GAME_LIST_LIMIT = 200
let PRICE_LIST_LIMIT = 50

/// 是否设置了代理
///
/// - Returns: 代理设置情况
func getProxyStatus() -> Bool {
    guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue(),
        let url = URL(string: "https://www.baidu.com") else {
        return false
    }
    let proxies = CFNetworkCopyProxiesForURL((url as CFURL), proxySettings).takeUnretainedValue() as NSArray
    guard let settings = proxies.firstObject as? NSDictionary,
        let proxyType = settings.object(forKey: (kCFProxyTypeKey as String)) as? String else {
        return false
    }
    #if DEBUG
    if let hostName = settings.object(forKey: (kCFProxyHostNameKey as String)),
        let port = settings.object(forKey: (kCFProxyPortNumberKey as String)),
        let type = settings.object(forKey: (kCFProxyTypeKey)) {
        print("""
            host = \(hostName)
            port = \(port)
            type= \(type)
        """)
    }
    #endif
    return proxyType == (kCFProxyTypeNone as String)
}
