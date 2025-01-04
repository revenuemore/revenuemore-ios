// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsViewController.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Cocoa

class SubscriptionsViewController: NSViewController {
    
    fileprivate enum CellIdentifiers {
        static let CustomCell = "SubscriptionsTableViewCell"
    }
    
    enum SubscriptionSection {
        case active([SubscriptionsTableViewCell.ViewModel])
        case inactive([SubscriptionsTableViewCell.ViewModel])
    }
    
    // MARK: - PROPERTIES
    
    var viewModel = SubscriptionsViewModel()
    
    // MARK: - Component(s)
    
    lazy var tableView = NSTableView()
    lazy var scrollView = NSScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.didLoad = {[weak self] isPremium in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.title = isPremium ? "Premium" : "Not Premium"
            }
        }
        viewModel.fetchEntitlement()
    }
    
    // MARK: - Helper Function(s)
    
    private func setupUI() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        
        tableView = NSTableView(frame: scrollView.bounds)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.documentView = tableView
        
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("activeCellID"))
        column1.title = "Active"
        column1.width = 200
        tableView.addTableColumn(column1)
        
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("inacativeCellID"))
        column2.title = "Inactive"
        column2.width = 200
        tableView.addTableColumn(column2)
        
    }
}

extension SubscriptionsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard tableView.numberOfRows != -1 else { return 0 }
        let section = viewModel.sections[tableView.numberOfColumns]
        switch section {
        case .active(let entitlements):
            return entitlements.count
        case .inactive(let entitlements):
            return entitlements.count
        }
    }
}

extension SubscriptionsViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.CustomCell), owner: nil) as? SubscriptionsTableViewCell
        let section = viewModel.sections[tableView.numberOfColumns]
        
        switch section {
        case .active(let entitlements):
            let model = entitlements[row]
            cell?.configuration(model)
        case .inactive(let entitlements):
            let model = entitlements[row]
            cell?.configuration(model)
        }
    
        return cell
    }
}
