//
//  Nation.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/19.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation
import Alamofire

enum EShopURL: URLConvertible, URLRequestConvertible {
    struct Option {
        var locale: String?
        var limit: Int?
        var shop: String?
        var offset: Int?
    }
    enum JapConfig {
        case current, coming, alt
        var path: String {
            switch self {
            case .current:
                return "/data/software/xml-system/switch-onsale.xml"
            case .coming:
                return "/data/software/xml-system/switch-coming.xml"
            case .alt:
                return "/api/search/title?category=products&pf=switch&q=*&count=25"
            }
        }
    }
    case us(Option)
    case eu(Option)
    case price(String, [String])
    case jap(JapConfig)
    
    func asURL() throws -> URL {
        switch self {
        case .us:
            return URL(string: "http://www.nintendo.com/json/content/get/filter/game?system=switch&sort=title&direction=asc")!
        case .eu(let options):
            let locale = options.locale ?? "en"
            return URL(string: "http://search.nintendo-europe.com/\(locale.lowercased())/select")!
        case .price:
            return URL(string: "https://api.ec.nintendo.com/v1/price?lang=en")!
        case .jap(let config):
            let baseURL = URL(string: "https://www.nintendo.co.jp")
            return URL(string: config.path, relativeTo: baseURL)!
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: try asURL())
        switch self {
        case .us(let options):
            let shop = options.shop ??  "ncom"
            request = try URLEncoding.queryString.encode(request, with: [
                "limit": options.limit ?? 200,
                "offset": options.offset ?? 0,
                "shop": shop == "all" ? ["ncom", "retail"] : shop
            ])
        case .eu(let options):
            request = try URLEncoding.queryString.encode(request, with: [
                "rows": options.limit ?? 9999,
                "q": "*",
                "sort": "sorting_title asc",
                "start": 0,
                "wt": "json"
                ])
        case .price(let country, let friendIds):
            request = try URLEncoding.queryString.encode(request, with: [
                "country": country,
                "limit": PRICE_LIST_LIMIT,
                "ids": friendIds
                ])
        default:
            break
        }
        return request
    }
}
