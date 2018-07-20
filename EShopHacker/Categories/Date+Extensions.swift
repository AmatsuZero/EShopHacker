//
//  Date+Extensions.swift
//  EShopHacker
//
//  Created by Jiang,Zhenhua on 2018/7/20.
//  Copyright © 2018年 Daubert. All rights reserved.
//

import Foundation

extension Date {
    // Convert the ISO8601 sting to date
    init?(isoDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:isoDate)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        guard let finalDate = calendar.date(from:components) else { return nil }
        self.init(timeInterval: 0, since: finalDate)
    }
}

extension String {
    var isoDate: Date? {
        guard !isEmpty else { return nil }
        return Date(isoDate: self)
    }
}
