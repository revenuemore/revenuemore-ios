// 
//  See LICENSE.text for this project’s licensing information.
//
//  MainViewModel.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI
import RevenueMore

@MainActor
class MainViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var isSuccess: Bool = false
    @Published var hasError: String?
    @Published var products: [RevenueMoreProduct] = []
    
    // MARK: - Helper Function(s)
    
    func fetchOfferings() {
        Task {
            isLoading = true
            do {
                let products = try await RevenueMore.shared.getOfferings()
                self.products = products.currentOffering?.products ?? []
            } catch {
                isError = true
                self.hasError = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func purchase(product: RevenueMoreProduct) {
        Task {
            isLoading = true
            do {
                try await RevenueMore.shared.purchase(product: product)
                isSuccess = true
            } catch {
                isError = true
                self.hasError = error.localizedDescription
            }
        }
    }
}
