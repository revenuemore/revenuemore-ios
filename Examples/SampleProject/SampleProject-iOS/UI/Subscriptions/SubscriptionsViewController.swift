// 
//  See LICENSE.text for this project’s licensing information.
//
//  SubscriptionsViewController.swift

//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 18.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController {
    
    enum SubscriptionSection {
        case active([SubscriptionsTableViewCell.ViewModel])
        case inactive([SubscriptionsTableViewCell.ViewModel])
    }

    // MARK: - PROPERTIES
    
    var viewModel = SubscriptionsViewModel()
    
    // MARK: - IBOUTLET(s)
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LIFE CYCLE(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(for: SubscriptionsTableViewCell.self)

        viewModel.didLoad = {[weak self] isPremium in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.title = isPremium ? "Premium" : "Not Premium"
            }
        }
        viewModel.fetchEntitlement()
    }

}

// MARK: - UITableViewDataSource

extension SubscriptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        switch section {
        case .active(let entitlements):
            return entitlements.count
        case .inactive(let entitlements):
            return entitlements.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(for: SubscriptionsTableViewCell.self, at: indexPath)
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .active(let entitlements):
            let model = entitlements[indexPath.row]
            cell.configuration(model)
        case .inactive(let entitlements):
            let model = entitlements[indexPath.row]
            cell.configuration(model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.sections[section]
        switch section {
        case .active(let array):
            return "Active"
        case .inactive(let array):
            return "Expired"
        }
    }
    
}
