//
//  NSDate.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

extension NSDate {
    
    var headerFormattedString: String {
        let dateFormatter = DateFormatter()
        let template = "MMM dd, hh:mm"
        let locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: template, options:0, locale:locale)
        
        dateFormatter.setLocalizedDateFormatFromTemplate(format!)
        
        var dateTimeString = dateFormatter.string(from: self as Date)
        
        if Calendar.current.isDateInToday(self as Date) {
            dateTimeString = "Today, " + dateTimeString
        }
        else {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
            let weekDay = dateFormatter.string(from: self as Date)
            dateTimeString = weekDay + ", " + dateTimeString
        }
        
        return dateTimeString
    }
}
