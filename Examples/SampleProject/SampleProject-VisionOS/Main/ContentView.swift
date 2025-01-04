// 
//  See LICENSE.text for this project’s licensing information.
//
//  ContentView.swift
//
//  SampleProject-VisionOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    
    // MARK: - Properties
    
    @StateObject var viewModel = MainViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(viewModel.products, id: \.self) { product in
                    HStack {
                        Text(product.displayName)
                        Text(product.displayPrice)
                    }//: HStack
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .onTapGesture {
                        viewModel.purchase(product: product)
                    }
                }//: ForEach
            }//: VStack
            .padding()
            .task {
                viewModel.fetchOfferings()
            }
            .alert(viewModel.hasError ?? "-", isPresented: $viewModel.isError) {
                
            }
            .toolbar {
                Button("Show Subscriptions Manage") {
                    viewModel.showSubscriptionManage()
                }
            }
        }
    }
}
