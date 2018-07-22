//
//  Network.swift
//  EShopHackerTests
//
//  Created by Jiang,Zhenhua on 2018/7/20.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import XCTest
import RxSwift
@testable import EShopHacker

class Network: XCTestCase {
    
    private let bag = DisposeBag()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGameUS()  {
        let expectation = XCTestExpectation(description: "Fetch JAP Games Info")
        SwithEShop.shared.gamesAmerica().subscribe(onNext: {
            print($0)
        }, onError: {
            XCTFail($0.localizedDescription)
        }, onCompleted: {
            expectation.fulfill()
        }).disposed(by: bag)
        wait(for: [expectation], timeout: 3000)
    }

    func testGameJAP() {
        let expectation = XCTestExpectation(description: "Fetch JAP Games Info")
        SwithEShop.shared.gamesJapan().subscribe(onNext: {
            print($0)
        }, onError: {
            XCTFail($0.localizedDescription)
        }, onCompleted: {
            expectation.fulfill()
        }).disposed(by: bag)
        wait(for: [expectation], timeout: 3)
    }
    
    func testGameEU() {
        let expectation = XCTestExpectation(description: "Fetch EU Games Info")
        SwithEShop.shared.gamesEurope().subscribe(onNext: {
            print($0)
        }, onError: {
            XCTFail($0.localizedDescription)
        }, onCompleted: {
            expectation.fulfill()
        }).disposed(by: bag)
        wait(for: [expectation], timeout: 30)
    }
    
    func testAmericaShops() {
        let expectation = XCTestExpectation(description: "Gets all active eshops on american countries")
        SwithEShop.shared.getShopsAmerica().subscribe(onNext: {
            print($0)
        }, onError: {
            XCTFail($0.localizedDescription)
        }, onCompleted: {
            expectation.fulfill()
        }).disposed(by: bag)
         wait(for: [expectation], timeout: 30)
    }
}
