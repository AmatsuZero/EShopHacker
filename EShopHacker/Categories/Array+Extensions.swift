//
//  Array+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/20.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
import RxSwift

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
    
    func slice(_ startIndex: Int, _ length: Int? = nil) -> Array {
        return length != nil
            ? Array(self[startIndex...].prefix(length!))
            : Array(self[startIndex...])
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}

// Unfortunately the extra type annotations are required, otherwise the compiler gives an incomprehensible error.
extension Observable where Element: OptionalType {
    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.empty()
        }
    }
}
