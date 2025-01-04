// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsViewModel.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 18.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import RevenueMore

class SubscriptionsViewModel: NSObject {
    
    // MARK: - PROPERTIES
    
    var didLoad: ((Bool) -> Void)?
    var sections: [SubscriptionsViewController.SubscriptionSection] = []
    
    // MARK: - HELPER METHOD(s)
    
    func fetchEntitlement() {
        RevenueMore.shared.getEntitlements {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let entitlements):
                
                let activeEntitlements = entitlements.activeEntitlements.map {
                    SubscriptionsTableViewCell.ViewModel(
                        title: $0.displayName ?? "-",
                        price: AppFormatters.formatMoneyFromString(String($0.price ?? 0), currency: $0.currency) ?? "",
                        startDate: "Start: " + AppFormatters.date2String(Date(timeIntervalSince1970: ($0.startDate ?? 0) / 1000), format: .fullMonthStyle),
                        endDate: "End: " + AppFormatters.date2String(Date(timeIntervalSince1970: ($0.expiresDate ?? 0) / 1000), format: .fullMonthStyle)
                        )
                }
                self.sections.append(.active(activeEntitlements))
                
                let expiredEntitlements = entitlements.expiredEntitlements.map {
                    SubscriptionsTableViewCell.ViewModel(
                        title: $0.displayName ?? "-",
                        price: AppFormatters.formatMoneyFromString(String($0.price ?? 0), currency: $0.currency) ?? "",
                        startDate: "Start: " + AppFormatters.date2String(Date(timeIntervalSince1970: ($0.startDate ?? 0) / 1000), format: .fullMonthStyle),
                        endDate: "End: " + AppFormatters.date2String(Date(timeIntervalSince1970: ($0.expiresDate ?? 0) / 1000), format: .fullMonthStyle)
                        )
                }
                        
                self.sections.append(.inactive(expiredEntitlements))

                self.didLoad?(entitlements.isPremium)
            case .failure(let error):
                print(error.description)
            }
        }
    }
}
