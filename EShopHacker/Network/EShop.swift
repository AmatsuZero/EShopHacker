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
import GDGeoData

final class SwithEShop {
    static let shared = SwithEShop()
    private lazy var sessionManager: SessionManager = {
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    }()
    
    func gamesAmerica(limit: Int? = nil,
                      offset: Int = 0,
                      shop: String = "ncom") -> Observable<[GameUS]> {
        return Observable<[GameUS]>.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self._gamesAmerica(limit: limit, offset: offset, shop: shop) {
                (error, result) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(result)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
            }.share(replay: 1, scope: .whileConnected)
    }
    
    private func _gamesAmerica(limit: Int? = nil,
                               offset: Int = 0,
                               shop: String = "ncom",
                               games: [GameUS] = [],
                               completionHandler: @escaping (Error?, [GameUS]) -> Void) {
        var opt = EShopURL.Option()
        opt.limit = limit ?? GAME_LIST_LIMIT
        opt.shop = shop
        sessionManager
            .request(EShopURL.us(opt))
            .validate()
            .responseData { [weak self] response in
                guard let `self` = self, response.error == nil else {
                    completionHandler(response.error, [])
                    return
                }
                guard let data = response.data,
                    let json = try? JSON(data: data),
                    let game = json["games"]["game"].array else {
                        completionHandler(nil, [])
                        return
                }
                let filteredGames = game.map { GameUS(json: $0) }
                let accumulatedGames = (games + filteredGames)
                    .unique { $0.slug ?? "" }
                if limit == nil,
                    filteredGames.count + offset < (json["filter"]["total"].int ?? 0) {
                    self._gamesAmerica(limit: limit,
                                       offset: offset + (limit ?? GAME_LIST_LIMIT),
                                       shop: shop,
                                       games: accumulatedGames,
                                       completionHandler: completionHandler)
                } else {
                    completionHandler(nil, accumulatedGames)
                }
        }
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
    
    func getPrices(alpha2Name: String, gameIds: [String], country: String) -> Observable<PriceResponse?> {
        return Observable<PriceResponse?>.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self._getPrices(alpha2Name: alpha2Name, gameIds: gameIds, country: country) { (error, result) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(result)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
            }.share(replay: 1, scope: .whileConnected)
    }
    
    private func _getPrices(alpha2Name: String,
                            gameIds: [String],
                            offset: Int = 0,
                            country: String,
                            prices: [PriceResponse.TitleData] = [],
                            completionHandler: @escaping (Error?, PriceResponse?) -> Void) {
        let filteredIds = gameIds.slice(offset, offset + PRICE_LIST_LIMIT)
        sessionManager
            .request(EShopURL.price(alpha2Name, filteredIds))
            .validate()
            .responseData { [weak self] response in
                guard let `self` = self, response.error == nil else {
                    completionHandler(response.error, nil)
                    return
                }
                guard let data = response.data,
                    let json = try? JSON(data: data) else {
                        completionHandler(nil, nil)
                        return
                }
                var priceResponse = PriceResponse(json: json)
                priceResponse.country = PriceResponse.CountryData(alpha2: alpha2Name, name: country)
                if let p = priceResponse.prices, p.count + offset < gameIds.count {
                    let accumulatedPrices = prices + p
                    self._getPrices(alpha2Name: alpha2Name,
                                    gameIds: gameIds,
                                    offset: offset + PRICE_LIST_LIMIT,
                                    country: country,
                                    prices: accumulatedPrices,
                                    completionHandler: completionHandler)
                } else if priceResponse.prices != nil {
                    priceResponse.prices! += prices
                    completionHandler(nil, priceResponse)
                } else {
                    completionHandler(nil, priceResponse)
                }
        }
    }
}

extension SwithEShop {
    
    struct FormattedPriceData {
        let code: String?
        let country: String?
        let currency: [PriceResponse.TitleData.PriceData]?
        let region: Int
    }
    
    func getShopsByCountryCodes(countryCodes:[GDCountry], gamecode: String, region: Region) -> Observable<[FormattedPriceData]> {
        let observes = countryCodes
            .filter { $0.alpha2 != nil }
            .map { self.getPrices(alpha2Name: $0.alpha2!, gameIds: [gamecode], country: $0.name) }
        let dataFilter: (PriceResponse?) -> Bool = { data -> Bool in
            guard let response = data else {
                return false
            }
            guard let prices = response.prices, !prices.isEmpty  else {
                return false
            }
            return prices.first?.regularPrice != nil
        }
        return Observable.merge(observes)
            .filter(dataFilter)
            .map {
                FormattedPriceData(code: $0?.country?.alpha2,
                                   country: $0?.country?.name,
                                   currency: $0?.prices?.first?.regularPrice,
                                   region: region.rawValue)
            }
            .toArray()
    }
    
    func getShopsAmerica() -> Observable<[[FormattedPriceData]]> {
        let subregions = GDRegion.regions
            .filter { $0.name == "Americas" }
            .first!
            .subRegions.map { $0.countries }
            .map {
                self.getShopsByCountryCodes(countryCodes: $0,
                                            gamecode: GAME_CHECK_CODE_US,
                                            region: .americas)
        }
        return Observable.merge(subregions).toArray()
    }
}
