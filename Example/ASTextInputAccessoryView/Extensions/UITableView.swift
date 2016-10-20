//
//  UITableView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation
import UIKit

public extension UITableView {
    
    func scrollToLastCell(_ atScrollPosition: UITableViewScrollPosition = .none, animated: Bool = true) {
        
        guard let lastIndexPath = lastIndexPath else {
                return
        }
        
        scrollToRow(at: lastIndexPath, at: atScrollPosition, animated: animated)
    }
    
    
    public var lastIndexPath: IndexPath? {
        
        guard
            let numberOfSections = dataSource?.numberOfSections?(in: self),
            let numberOfRows = dataSource?.tableView(self, numberOfRowsInSection: numberOfSections - 1)
            , numberOfRows > 0 else {
                return nil
        }
        
        return IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
    }
}


