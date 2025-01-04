// 
//  See LICENSE.text for this project’s licensing information.
//
//  AppFormatters.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

enum AppDateFormat: String {
    /// 15.10.2015
    case dotStyle = "dd.MM.YYYY"
    case dashStyle = "YYYY-MM-dd"
    case fullMonthStyle = "dd MMMM yyyy"
    case slashStyle = "d/M/yyyy"
    case full = "dd/MM/yy HH:mm"
}

struct PaperDateFormat {
    var day: String = ""
    var monthAndYear: String = ""
}

final class AppFormatters {
    
    static var locale = Locale.current
    
    static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = AppFormatters.locale
        formatter.currencySymbol = ""
        return formatter
    }()
    
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.percentSymbol = "%"
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public static func date2String(_ date: Date,
                                   format: AppDateFormat? = nil,
                                   style: DateFormatter.Style = .medium) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = AppFormatters.locale
        if format != nil {
            formatter.dateFormat = format!.rawValue
        } else {
            formatter.dateStyle = style
        }
        
        return formatter.string(from: date)
    }
    
    static func formatMoneyFromString(_ value: String?, currency: String?) -> String? {
        guard let money = value, let currency = currency else { return nil }
        
        if let doubleMoney = Double(money),
           let moneyString = moneyFormatter.string(from: NSNumber.init(value: doubleMoney/1000)) {
            return moneyString + " \(currency)"
        }
        
        return nil
    }
}
