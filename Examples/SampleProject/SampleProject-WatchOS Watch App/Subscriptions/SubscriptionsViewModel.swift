// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsViewModel.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI
import RevenueMore

@MainActor
class SubscriptionsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isError: Bool = false
    @Published var hasError: String?
    @Published var activeSubscriptions: [String] = []
    @Published var inactiveSubscriptions: [String] = []
    
    // MARK: - Helper Function(s)
    
   func fetchEntitlements() {
       Task {
           do {
               let entitlements = try await RevenueMore.shared.getEntitlements()
               activeSubscriptions = entitlements.activeEntitlements.map { $0.productId ?? "-" }
               inactiveSubscriptions = entitlements.expiredEntitlements.map { $0.productId ?? "-" }
           } catch {
               isError = true
               self.hasError = error.localizedDescription
           }
       }
    }
}
