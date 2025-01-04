// 
//  See LICENSE.text for this project’s licensing information.
//
//  ViewController.swift
//
//  SampleProject-MacOS
//
//  Created by Bilal Durnagöl on 20.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let PriceCell = "PriceCellID"
        static let PerPriceCell = "PerPriceCellID"
    }
    
    // MARK: - Properties
    
    var viewModel: MainViewModel = MainViewModel()
    
    // MARK: - Component(s)
    
    lazy var tableView = NSTableView()
    lazy var scrollView = NSScrollView()
    lazy var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(subscriptionButton)
        stackView.addArrangedSubview(restoreButton)
        stackView.addArrangedSubview(manageSubscriptionButton)
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var loginButton: NSButton = {
       let button = NSButton(title: "Login", target: self, action: #selector(loginButtonTapped))
        return button
    }()
    
    lazy var logoutButton: NSButton = {
       let button = NSButton(title: "Logout", target: self, action: #selector(logoutButtonTapped))
        return button
    }()
    
    lazy var subscriptionButton: NSButton = {
       let button = NSButton(title: "Subscriptions", target: self, action: #selector(subscriptionButtonTapped))
        return button
    }()
    
    lazy var restoreButton: NSButton = {
       let button = NSButton(title: "Restore Payment", target: self, action: #selector(restorePaymentButtonTapped))
        return button
    }()
    
    lazy var manageSubscriptionButton: NSButton = {
       let button = NSButton(title: "Show Manage Subscription", target: self, action: #selector(showManageSubscriptionButtonTapped))
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetchOfferings()
        viewModel.listenTransactions()
        subscriptions()
    }
    
    // MARK: - Helper Method(s)
    
    private func setupUI() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
  
        self.view.addSubview(scrollView)
        self.view.addSubview(stackView)
        
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.stackView.topAnchor).isActive = true
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        
        stackView.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableView = NSTableView(frame: scrollView.bounds)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.documentView = tableView
        
        
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("NameCellID"))
        column1.title = "Display Name"
        column1.width = 150
        tableView.addTableColumn(column1)
        
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PriceCellID"))
        column2.title = "Price"
        column2.width = 100
        tableView.addTableColumn(column2)
        
        let column3 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PerPriceCellID"))
        column3.title = "Price Per Month"
        column3.width = 100
        tableView.addTableColumn(column3)
   
    }
    
    private func subscriptions() {
        viewModel.didFinishLoad = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.didFinishWithFailure = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showSheetAlert(with: message)
            }
        }
        
        viewModel.loginDidFinishLoad = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showSheetAlert(with: message)
            }
        }
    }
    
    private func switchToViewController(_ viewController: NSViewController) {
         for subview in self.view.subviews {
             subview.removeFromSuperview()
         }
         self.addChild(viewController)
         viewController.view.frame = self.view.bounds
         self.view.addSubview(viewController.view)
     }
    
    private func showSheetAlert(with message: String) {
        let alert = NSAlert()
        alert.messageText = "Alert"
        alert.informativeText = message
        guard let window = self.view.window else { return }
        alert.beginSheetModal(for: window) { _ in }
    }
    
    private func showLoginAlert() {
        
        let alert = NSAlert()
        alert.messageText = "Login"
        alert.informativeText = "Please enter your user id."
        alert.alertStyle = .informational
        
        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputField.placeholderString = "User Id"
        
        alert.accessoryView = inputField
        
        alert.addButton(withTitle: "Login")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            viewModel.login(with: inputField.stringValue)
        }
    }
    
    @objc func loginButtonTapped(_ sender: Any) {
        showLoginAlert()
    }
    
    @objc func logoutButtonTapped(_ sender: Any) {
        viewModel.logout()
    }
    
    @objc func subscriptionButtonTapped(_ sender: Any) {
        presentInNewWindow(viewController: SubscriptionsViewController())
    }
    
    @objc func restorePaymentButtonTapped(_ sender: Any) {
        viewModel.restorePayment()
    }
    
    @objc func showManageSubscriptionButtonTapped(_ sender: Any) {
        viewModel.showManageSubscriptions()
    }
}

extension MainViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.products.count
    }
}

extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = NSUserInterfaceItemIdentifier("Cell")
        var cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTextField
        if cell == nil {
            cell = NSTextField()
            cell?.identifier = identifier
            cell?.isEditable = false
            cell?.isBordered = false
            cell?.backgroundColor = .clear
        }
        
        let product = viewModel.products[row]
        if tableColumn == tableView.tableColumns[0] {
            cell?.stringValue = product.displayName
        } else if tableColumn == tableView.tableColumns[1] {
            cell?.stringValue = product.displayPrice
        } else if tableColumn == tableView.tableColumns[2] {
            cell?.stringValue = product.displayPricePerMonth ?? "-"
        }
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        let selectedRow = tableView.selectedRow
        if selectedRow != -1 {
            let product = viewModel.products[selectedRow]
            viewModel.purchase(product: product)
        } else {
            print("Hiçbir satır seçili değil.")
        }
    }
}

extension NSViewController {

   func presentInNewWindow(viewController: NSViewController) {
      let window = NSWindow(contentViewController: viewController)

      var rect = window.contentRect(forFrameRect: window.frame)
      // Set your frame width here
      rect.size = .init(width: 1000, height: 600)
      let frame = window.frameRect(forContentRect: rect)
      window.setFrame(frame, display: true, animate: true)

      window.makeKeyAndOrderFront(self)
      let windowVC = NSWindowController(window: window)
      windowVC.showWindow(self)
  }
}
