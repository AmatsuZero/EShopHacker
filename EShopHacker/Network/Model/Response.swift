//
//  Response.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/19.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
import SWXMLHash
import SwiftyJSON

protocol GameCodeProtocol {
    var gameCode: String? { get }
    var uid: String? { get }
}

enum Region: Int {
    case americas = 1, europe, asia
    
    var pattern: String {
        switch self {
        case .americas:
            return "HAC\\w(\\w{4})"
        case .europe:
            return "HAC\\w(\\w{4})"
        case .asia:
            return "\\/HAC(\\w{4})"
        }
    }
    
    var regex: NSRegularExpression? {
       return try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
}

struct GameUS: Codable, Hashable, Equatable, GameCodeProtocol {
    var gameCode: String? {
        return code?.matches(for: Region.americas.pattern).first
    }
    
    var uid: String? {
        return nsUID
    }
    
    var hashValue: Int {
        return slug?.hashValue ?? 0
    }
    
    static func == (left:GameUS, right:GameUS) -> Bool {
        return left.slug == right.slug
    }
    
    enum CodingKeys: String, CodingKey {
        case code = "game_code"
        case isBuyOnline = "buyonline"
        case frontBoxArt = "front_box_art"
        case eshopPrice = "eshop_price"
        case nsUID = "nsuid"
        case videoLink = "video_link"
        case numberOfPlayers = "number_of_players"
        case caPrice = "ca_price"
        case id = "id"
        case title = "title"
        case system = "system"
        case canFreeToStart = "free_to_start"
        case isDigitalDownload = " digitaldownload"
        case releaseDate = "release_date"
        case categories = "categories"
        case slug = "slug"
        case canBuyItNow = "buyitnow"
    }
    
    let code: String?
    let isBuyOnline: Bool?
    let frontBoxArt: String?
    let eshopPrice: Double?
    let nsUID: String?
    let videoLink: String?
    let numberOfPlayers: String?
    let caPrice: Double?
    let id: String?
    let title: String?
    let system: String?
    let canFreeToStart: Bool?
    let isDigitalDownload: Bool?
    let releaseDate: String?
    let categories: [String]?
    let slug: String?
    let canBuyItNow: Bool?
    
    init(json: JSON) {
        code = json["game_code"].string
        isBuyOnline = json["buyonline"].string?.toBool()
        frontBoxArt = json["front_box_art"].string
        eshopPrice = json["eshop_price"].string?.toDouble()
        nsUID = json["nsuid"].string
        videoLink = json["video_link"].string
        numberOfPlayers = json["number_of_players"].string
        caPrice = json["ca_price"].string?.toDouble()
        id = json["id"].string
        title = json["title"].string
        system = json["system"].string
        canFreeToStart = json["free_to_start"].string?.toBool()
        isDigitalDownload = json["digitaldownload"].string?.toBool()
        releaseDate = json["release_date"].string
        categories = json["categories"]["category"].array?.map { $0.string }.compactMap { $0 }
        slug = json["slug"].string
        canBuyItNow = json["buyitnow"].string?.toBool()
    }
}

struct GameEU: Codable, GameCodeProtocol {
    var gameCode: String? {
        guard let code = productCode?.first else {
            return nil
        }
        return code.matches(for: Region.europe.pattern).first
    }
    
    var uid: String? {
        return nsUIDs?.first
    }
    
    enum CodingKeys: String, CodingKey {
        case ageRatingType = "age_rating_type"
        case ageRatingValue = "age_rating_value"
        case copyright = "copyright_s"
        case developer = "developer"
        case excerpt = "excerpt"
        case fsID = "fs_id"
        case gameSeries = "game_series_t"
        case giftFinderCarouselImageURL = "gift_finder_carousel_image_url_s"
        case giftFinderDescription = "gift_finder_description_s"
        case giftFinderDetailPageStoreLink = "gift_finder_detail_page_store_link_s"
        case giftFinderWishlistImageURL = "gift_finder_wishlist_image_url_s"
        case imageURL = "image_url"
        case sqImageURL = "image_url_sq_s"
        case tmImageURL = "image_url_tm_s"
        case originallyFor = "originally_for_t"
        case prettyAgerating = "pretty_agerating_s"
        case prettyDate = "pretty_date_s"
        case publisher = "publisher"
        case sortingTitle = "sorting_title"
        case title = "title"
        case type = "type"
        case url = "url"
        case isAddonContent = "add_on_content_b"
        case isClubNintendo = "club_nintendo"
        case isNearFieldComm = "near_field_comm_b"
        case isPhysicalVersion = "physical_version_b"
        case isPlayModeHandHeld = "play_mode_handheld_mode_b"
        case isPlayModeTableTop = "play_mode_tabletop_mode_b"
        case isPlayModeTV = "play_mode_tv_mode_b"
        case changeDate = "change_date"
        case dateFrom = "date_from"
        case priority = "priority"
        case ageRatingSorting = "age_rating_sorting_i"
        case playersFrom = "players_from"
        case playersTo = "players_to"
        case compatibleController = "compatible_controller"
        case gameCategories = "game_category"
        case gameCategoriesTxt = "game_categories_txt"
        case avialableLanguages = "language_availability"
        case nsUIDs = "nsuid_txt"
        case playableOn = "playable_on_txt"
        case productCode = "product_code_txt"
        case systemNames = "system_names_txt"
        case systemTypes = "system_type"
        case titleExtras = "title_extras_txt"
    }
    let ageRatingType: String?
    let ageRatingValue: String?
    let copyright: String?
    let developer: String?
    let excerpt: String?
    let fsID: String?
    let gameSeries: String?
    let giftFinderCarouselImageURL: String?
    let giftFinderDescription: String?
    let giftFinderDetailPageStoreLink: String?
    let giftFinderWishlistImageURL: String?
    let imageURL: String?
    let sqImageURL: String?
    let tmImageURL: String?
    let originallyFor: String?
    let prettyAgerating: String?
    let prettyDate: String?
    let publisher: String?
    let sortingTitle: String?
    let title: String?
    let type: String?
    let url: String?
    let isAddonContent: Bool?
    let isClubNintendo: Bool?
    let isNearFieldComm: Bool?
    let isPhysicalVersion: Bool?
    let isPlayModeHandHeld: Bool?
    let isPlayModeTableTop: Bool?
    let isPlayModeTV: Bool?
    let changeDate: Date?
    let dateFrom: Date?
    let priority: Date?
    let ageRatingSorting: Int?
    let playersFrom: Int?
    let playersTo: Int?
    let compatibleController: [String]?
    let gameCategories: [String]?
    let gameCategoriesTxt: [String]?
    let avialableLanguages: [String]?
    let nsUIDs: [String]?
    let playableOn: [String]?
    let productCode: [String]?
    let systemNames: [String]?
    let systemTypes: [String]?
    let titleExtras: [String]?
    
    init(json: JSON) {
        ageRatingType = json["age_rating_type"].string
        ageRatingValue = json["age_rating_value"].string
        copyright = json["copyright_s"].string
        developer = json["developer"].string
        excerpt = json["excerpt"].string
        fsID = json["fs_id"].string
        gameSeries = json["game_series_t"].string
        giftFinderCarouselImageURL = json["gift_finder_carousel_image_url_s"].string
        giftFinderDescription = json["gift_finder_description_s"].string
        giftFinderDetailPageStoreLink = json["gift_finder_detail_page_store_link_s"].string
        giftFinderWishlistImageURL = json["gift_finder_wishlist_image_url_s"].string
        imageURL = json["image_url"].string
        sqImageURL = json["image_url_sq_s"].string
        tmImageURL = json["image_url_tm_s"].string
        originallyFor = json["originally_for_t"].string
        prettyAgerating = json["pretty_agerating_s"].string
        prettyDate = json["pretty_date_s"].string
        publisher = json["publisher"].string
        sortingTitle = json["sorting_title"].string
        title = json["title"].string
        type = json["type"].string
        url = json["url"].string
        isAddonContent = json["add_on_content_b"].bool
        isClubNintendo = json["club_nintendo"].bool
        isNearFieldComm = json["near_field_comm_b"].bool
        isPhysicalVersion = json["physical_version_b"].bool
        isPlayModeHandHeld = json["play_mode_handheld_mode_b"].bool
        isPlayModeTableTop = json["play_mode_tabletop_mode_b"].bool
        isPlayModeTV = json["play_mode_tv_mode_b"].bool
        changeDate = json["change_date"].string != nil ? json["change_date"].stringValue.isoDate : nil
        dateFrom = json["date_from"].string != nil ? json["date_form"].stringValue.isoDate : nil
        priority = json["priority"].string != nil ? json["priority"].stringValue.isoDate : nil
        ageRatingSorting = json["age_rating_sorting_i"].int
        playersFrom = json["players_from"].int
        playersTo = json["players_to"].int
        compatibleController = json["compatible_controller"].array?.map { $0.string }.compactMap { $0 }
        gameCategories = json["nsuid_txt"].array?.map { $0.stringValue }.compactMap { $0 }
        gameCategoriesTxt = json["game_categories_txt"].array?.map { $0.string }.compactMap { $0 }
        avialableLanguages = json["language_availability"].array?.map { $0.string }.compactMap { $0 }
        nsUIDs = json["nsuid_txt"].array?.map { $0.stringValue }.compactMap { $0 }
        playableOn = json["playable_on_txt"].array?.map { $0.string }.compactMap { $0 }
        productCode = json["product_code_txt"].array?.map { $0.string }.compactMap { $0 }
        systemNames = json["system_names_txt"].array?.map { $0.string }.compactMap { $0 }
        systemTypes = json["system_type"].array?.map { $0.string }.compactMap { $0 }
        titleExtras = json["title_extras_txt"].array?.map { $0.string }.compactMap { $0 }
    }
}

struct GameJP: Codable, GameCodeProtocol {
    var gameCode: String? {
        return screenShotImageURL?.matches(for: Region.asia.pattern).first
    }
    
    var uid: String? {
        return linkURL?.matches(for: "\\d{14}").first
    }
    
    enum CodingKeys: String, CodingKey  {
        case linkURL = "LinkURL"
        case linkTarget = "LinkTarget"
        case screenShotImageURL = "ScreenshotImgURL"
        case screenShotImageURLComing = "ScreenshotImgURLComing"
        case titleName = "TitleName"
        case titleNameRuby = "TitleNameRuby"
        case softType = "SoftType"
        case salesDate = "D"
        case salesDateStr = "SalesDateStr"
        case markerName = "MakerName"
        case hard = "hard"
        case memo = "memo"
    }
    let linkURL: String?
    let linkTarget: String?
    let screenShotImageURL: String?
    let screenShotImageURLComing: String?
    let titleName: String?
    let titleNameRuby: String?
    let softType: String?
    let salesDate: Date?
    let salesDateStr: String?
    let markerName: String?
    let hard: String?
    let memo: String?
    
    init(node: XMLIndexer) {
        linkURL = node["LinkURL"].element?.text
        linkTarget = node["LinkTarget"].element?.text
        screenShotImageURL = node["ScreenshotImgURL"].element?.text
        screenShotImageURLComing = node["ScreenshotImgURLComing"].element?.text
        titleName = node["TitleName"].element?.text
        titleNameRuby = node["TitleNameRuby"].element?.text
        softType = node["SoftType"].element?.text
        if let n = node["D"].element?.text, let stamp = TimeInterval(n) {
            salesDate = Date(timeIntervalSince1970: stamp)
        } else {
            salesDate = nil
        }
        salesDateStr = node["SalesDateStr"].element?.text
        markerName = node["MakerName"].element?.text
        hard = node["Hard"].element?.text
        memo = node["Memo"].element?.text
    }
}

struct PriceResponse: Codable {
    struct PriceError: Codable {
        let code: String?
        let message: String?
        
        init(json: JSON?) {
            code = json?["code"].string
            message = json?["message"].string
        }
    }
    struct TitleData: Codable {
        enum CodingKeys: String, CodingKey  {
            case titleID = "title_id"
            case salesStatus = "sales_status"
            case regularPrice = "regular_price"
        }
        struct PriceData: Codable {
            enum CodingKeys: String, CodingKey  {
                case amount = "amount"
                case currency = "currency"
                case rawValue = "raw_value"
            }
            let amount: String?
            let currency: String?
            let rawValue: String?
            
            init(json: JSON?) {
                amount = json?["amount"].string
                currency = json?["currency"].string
                rawValue = json?["raw_value"].string
            }
        }
        
        let titleID: Int?
        let salesStatus: String?
        let regularPrice: [PriceData]?
        
        init(json: JSON?) {
            titleID = json?["title_id"].int
            salesStatus = json?["sales_status"].string
            regularPrice = json?["regular_price"].array?.map { PriceData(json: $0) }
        }
    }
    
    struct CountryData: Codable {
        let alpha2: String?
        let name: String?
    }
    
    let error: PriceError?
    let personalized: Bool?
    var country: CountryData? = nil
    var prices: [TitleData]?
    
    init(json: JSON) {
        error = PriceError(json: json["error"])
        personalized = json["personalized"].bool
        prices = json["prices"].array?.map { TitleData(json: $0) }
    }
}

