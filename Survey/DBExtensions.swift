//
//  DBExtensions.swift
//  Survey
//
//  Created by Wesley Scheper on 06/12/15.
//  Copyright © 2015 Wesley Scheper. All rights reserved.
//

import UIKit

extension NSDate {
    
    // Creates and returns an NSDate from a date string in the yyyy-MM-dd'T'HH:mm:ss'Z' format
    class func dateFromString(dateString: String) -> NSDate {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.dateFromString(dateString)!
    }
    
    // Returns a String in yyyy-MM-dd'T'HH:mm:ss'Z' format from the date
    func dateString() -> String {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.stringFromDate(self)
    }
    
    // Returns a String in HH:mm:ss format from the date
    func simpleDateString() -> String {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.stringFromDate(self)
    }
}

extension NSDateComponents {
    
    // Returns a string in HH:mm:ss format from the date components
    func simpleDateString() -> String {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(self)
        
        return (date?.simpleDateString())!
    }
}

