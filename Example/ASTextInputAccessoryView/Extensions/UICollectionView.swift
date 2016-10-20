//
//  UICollectionView.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit


extension UICollectionView {
    
    public var lastIndexPath: IndexPath? {
        
        guard
            let numberOfSections = dataSource?.numberOfSections?(in: self),
            let numberOfItems = dataSource?.collectionView(self, numberOfItemsInSection: numberOfSections - 1)
            , numberOfItems > 0 else {
                return nil
        }
        
        return IndexPath(item: numberOfItems - 1, section: numberOfSections - 1)
    }
    
    func scrollToLastCell(_ atScrollPosition: UICollectionViewScrollPosition = UICollectionViewScrollPosition(), animated: Bool = true) {
        
        guard let lastIndexPath = lastIndexPath else {
            return
        }
        
        scrollToItem(at: lastIndexPath, at: atScrollPosition, animated: animated)
    }
}
