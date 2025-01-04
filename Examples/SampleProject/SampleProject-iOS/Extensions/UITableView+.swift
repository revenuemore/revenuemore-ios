// 
//  See LICENSE.text for this project’s licensing information.
//
//  UITableView+.swift
//
//  SampleProject-iOS
//
//  Created by Bilal Durnagöl on 18.11.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import UIKit

public extension UITableView{
    func registerNib<T: UITableViewCell>(for type: T.Type, bundle: Bundle? = nil) {
           let className = String(describing: type)
           let nib = UINib(nibName: className, bundle: bundle)
           register(nib, forCellReuseIdentifier: className)
    }
    
    func dequeueCell<T: UITableViewCell>(for type: T.Type, at indexPath: IndexPath) -> T{
        let className = String(describing: type)
        return dequeueReusableCell(withIdentifier: className, for: indexPath) as! T
    }
}
