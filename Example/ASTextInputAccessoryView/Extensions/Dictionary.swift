//
//  Dictionary.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

extension Dictionary where Key: NSDate, Value: _ArrayProtocol, Value.Iterator.Element: Message {
    
    var sortedKeys: [Key] {
        return keys.sorted(by: { $0.timeIntervalSince1970 < $1.timeIntervalSince1970})
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> Message {
        return self[sortedKeys[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).item]
    }
    
    func arrayForIndex(_ section: Int) -> [Message] {
        return self[sortedKeys[section]] as! [Message]
    }
}
