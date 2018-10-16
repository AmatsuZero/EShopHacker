//
//  DispatchTime+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/10/16.
//  Copyright © 2018 Daubert. All rights reserved.
//

import Foundation

public extension Int {
    
    public var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }
    
    public var second: DispatchTimeInterval {
        return seconds
    }
    
    public var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    public var millisecond: DispatchTimeInterval {
        return milliseconds
    }
    
}

public extension DispatchTimeInterval {
    public var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }
}
