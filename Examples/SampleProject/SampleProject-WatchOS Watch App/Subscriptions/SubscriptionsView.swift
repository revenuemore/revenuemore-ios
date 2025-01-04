// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsView.swift
//  SampleProject-WatchOS Watch App
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI

struct SubscriptionsView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel = SubscriptionsViewModel()
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            Section("Active") {
                ForEach(viewModel.activeSubscriptions, id: \.self) { subscription in
                    Text(subscription)
                }
            }//: Section
            
            Section("Inactive") {
                ForEach(viewModel.inactiveSubscriptions, id: \.self) { subscription in
                    Text(subscription)
                }
            }//: Section
        }//: ScrollView
        .task {
            viewModel.fetchEntitlements()
        }
        .alert(viewModel.hasError ?? "-", isPresented: $viewModel.isError) { }
    }
}
