// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsTableViewCell.swift

//  SampleProject-MacOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Cocoa

class SubscriptionsTableViewCell: NSTableCellView {
    struct ViewModel {
        var title: String
        var price: String
        var startDate: String
        var endDate: String
    }
    
    // MARK: - Component(s)
    
    lazy var titleLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        return label
    }()
    
    lazy var priceLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        return label
    }()
    
    lazy var startDateLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        return label
    }()
    
    lazy var endDateLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        return label
    }()
    
    lazy var verticalStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4.0
        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(bottomStackView)
        return stackView
    }()
    
    lazy var topStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4.0
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(priceLabel)
        return stackView
    }()
    
    lazy var bottomStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4.0
        stackView.addArrangedSubview(startDateLabel)
        stackView.addArrangedSubview(endDateLabel)
        return stackView
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Helper Function(s)
    
    private func setupUI() {
        addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            verticalStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configuration(_ viewModel: SubscriptionsTableViewCell.ViewModel) {
        titleLabel.stringValue = viewModel.title
        priceLabel.stringValue = viewModel.price
        startDateLabel.stringValue = viewModel.startDate
        endDateLabel.stringValue = viewModel.endDate
    }
}
