// 
//  See LICENSE.text for this project’s licensing information.
//
//  ViewController.swift
//  SampleProject-TvOS
//
//  Created by Bilal Durnagöl on 24.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: MainViewModel = MainViewModel()
    
    // MARK: - IBOutlet(s)
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptions()
        viewModel.fetchOfferings()
        viewModel.listenTransactions()
    }
    
    // MARK: - IBAction(s)
    
    @IBAction func didTapLogin(_ sender: Any) {
        showTextInputAlert(on: self)
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        viewModel.logout()
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        viewModel.restorePayment()
    }
    
    // MARK: - Helper Method(s)
    
    private func subscriptions() {
        viewModel.didFinishLoad = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.didFinishWithFailure = { [weak self] messge in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showAlert(on: self, with: messge)
            }
        }
        
        viewModel.loginDidFinishLoad = { [weak self] messge in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showAlert(on: self, with: messge)
            }
        }
    }
    
    func showTextInputAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Login",
            message: "Please enter your user id.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "User Id"
            textField.keyboardType = .default
            textField.autocapitalizationType = .none
        }
        
        let saveAction = UIAlertAction(title: "Login", style: .default) {[weak self] _ in
            if let textField = alert.textFields?.first,
               let userInput = textField.text, !userInput.isEmpty {
                self?.viewModel.login(with: userInput)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(on viewController: UIViewController, with messge: String) {
        let alert = UIAlertController(title: "Error", message: messge, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let product = viewModel.products[indexPath.row]
        cell.textLabel?.text = String(format: "%@ - %@ Month / %@", product.displayName, product.displayPrice, product.displayPricePerMonth ?? "-")
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = viewModel.products[indexPath.row]
        viewModel.purchase(product: product)
    }
}
