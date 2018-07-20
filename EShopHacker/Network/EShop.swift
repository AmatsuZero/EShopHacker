//
//  EShop.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/19.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift
import Alamofire
import SWXMLHash
import SwiftyJSON

final class SwithEShop {
    static let shared = SwithEShop()
    private lazy var sessionManager: SessionManager = {
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    }()
    
    //TODO: Handle offset
    func gamesAmerica(limit: Int? = nil,
                      offset: Int = 0,
                      shop: String = "ncom") -> Observable<[GameUS]> {
        var opt = EShopURL.Option()
        opt.limit = limit ?? 200
        opt.shop = shop
        let response = sessionManager.rx
            .request(urlRequest: EShopURL.us(opt))
            .validate()
            .data()
            .map { data -> [GameUS] in
                guard let json = try? JSON(data: data), let game = json["games"]["game"].array else {
                    return []
                }
                return game.map { GameUS(json: $0) }
        }
        return response.share(replay: 1, scope: .whileConnected)
    }
    
    func gamesJapan() -> Observable<[GameJP]> {
        let currentGames = sessionManager.rx
            .request(urlRequest: EShopURL.jap(.coming))
            .validate()
            .string()
            .map { string -> [GameJP] in
                let xml = SWXMLHash.parse(string)
                return xml["TitleInfoList"]["TitleInfo"]
                    .all
                    .map { GameJP(node: $0) }
        }
        
        let comingGames = sessionManager.rx
            .request(urlRequest: EShopURL.jap(.coming))
            .validate()
            .string()
            .map { string -> [GameJP] in
                let xml = SWXMLHash.parse(string)
                return xml["TitleInfoList"]["TitleInfo"]
                    .all
                    .map { GameJP(node: $0) }
        }
        return currentGames.concat(comingGames).share(replay: 1, scope: .whileConnected)
    }
    
    func gamesEurope(locale: String = "en", limit: Int = 9999) -> Observable<[GameEU]> {
        var opt = EShopURL.Option()
        opt.locale = locale
        opt.limit = limit
        return sessionManager.rx
            .request(urlRequest: EShopURL.eu(opt))
            .validate()
            .data()
            .map { data -> [GameEU] in
                guard let json = try? JSON(data: data), let docs = json["response"]["docs"].array else {
                    return []
                }
                return docs.map { GameEU(json: $0) }
            }
            .share(replay: 1, scope: .whileConnected)
    }
}
