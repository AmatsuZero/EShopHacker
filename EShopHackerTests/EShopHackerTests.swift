//
//  EShopHackerTests.swift
//  EShopHackerTests
//
//  Created by Jiang,Zhenhua on 2018/7/19.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import XCTest
import RxSwift
@testable import EShopHacker

class EShopHackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMerge() {
        let expectation = XCTestExpectation(description: "Merge Test")
        let disposeBag = DisposeBag()
        
        let subject1 = Observable<String>.create{ observer -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // your code here
                observer.onNext("s1")
                observer.onCompleted()
            }
            return Disposables.create()
            }.share(replay: 1, scope: .whileConnected)
        
        let subject2 = Observable<String>.create{ observer -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // your code here
                observer.onNext("s2")
                observer.onCompleted()
              //  observer.onError(NSError(domain: "dada", code: 109, userInfo: nil))
            }
            return Disposables.create()
        }.share(replay: 1, scope: .whileConnected)
        
        let observes = [subject1, subject2]
        Observable.merge(observes).toArray().subscribe(onNext: {
            print($0)
        }, onError: {
            XCTFail($0.localizedDescription)
        }, onCompleted: {
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3)
    }
}
