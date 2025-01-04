// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsTableViewCell.swift
//
//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 18.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import UIKit

class SubscriptionsTableViewCell: UITableViewCell {
    struct ViewModel {
        var title: String
        var price: String
        var startDate: String
        var endDate: String
    }
    
    // MARK: - IBOUTLET(s)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - HELPER METHOD(s)
    
    func configuration(_ viewModel: SubscriptionsTableViewCell.ViewModel) {
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.price
        startDateLabel.text = viewModel.startDate
        endDateLabel.text = viewModel.endDate
    }
}
