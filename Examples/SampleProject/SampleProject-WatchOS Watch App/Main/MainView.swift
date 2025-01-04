// 
//  See LICENSE.text for this project’s licensing information.
//
//  ContentView.swift
//  SampleProject-WatchOS Watch App
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel = MainViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                ForEach(viewModel.products, id: \.self) { product in
                    HStack {
                        Text(product.displayName)
                            .font(.caption)
                        Text(product.displayPrice)
                            .font(.caption)
                    }//: HStack
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .onTapGesture {
                        viewModel.purchase(product: product)
                    }
                }//: ForEach
                
                NavigationLink(destination: SubscriptionsView()) {
                    Text("Subscriptions")
                }//: NavigationLink
                
            }//: VStack
            .padding()
            .task {
                viewModel.fetchOfferings()
            }
            .alert(viewModel.hasError ?? "-", isPresented: $viewModel.isError) { }
        }
    }//: NavigationView
}
