// 
//  See LICENSE.text for this project’s licensing information.
//
//  MainViewModel.swift
//
//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 18.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
import RevenueMore

class MainViewModel: NSObject {
    
    // MARK: - Properties
    
    var didFinishLoad: (() -> Void)?
    var loginDidFinishLoad: ((String) -> Void)?
    var products: [RevenueMoreProduct] = []
    var didFinishWithFailure: ((String) -> Void)?
    
    // MARK: - Helper Method(s)
    
    func fetchOfferings() {
        RevenueMore.shared.getOfferings {[weak self] result in
            switch result {
            case .success(let offerings):
                self?.products = offerings.currentOffering?.products ?? []
                self?.didFinishLoad?()
            case .failure(let error):
                self?.didFinishWithFailure?(error.localizedDescription)
            }
        }
    }
    
    func purchase(product: RevenueMoreProduct) {
        RevenueMore.shared.purchase(product: product) {[weak self] result in
            switch result {
            case .success:
                print("Purchase successful")
            case .failure(let error):
                self?.didFinishWithFailure?(error.localizedDescription)
            }
        }
    }
    
    func login(with userId: String) {
        RevenueMore.shared.login(userId: userId) {[weak self] in
            self?.loginDidFinishLoad?("Login successful")
        }
    }
    
    func logout() {
        RevenueMore.shared.logout()
        loginDidFinishLoad?("Logout successful")
    }
    
    func restorePayment() {
        RevenueMore.shared.restorePayment {[weak self] result in
            switch result {
            case .success:
                print("Restore payment successful")
            case .failure(let error):
                self?.didFinishWithFailure?(error.localizedDescription)
            }
        }
    }
    
    func listenTransactions() {
        RevenueMore.shared.listenPaymentTransactions { result in
            switch result {
            case .success(let transaction):
                print("success: \(transaction.transactionIdentifier)")
            case .failure(let error):
                print("failure: \(error.description)")
            }
        }
    }
}
