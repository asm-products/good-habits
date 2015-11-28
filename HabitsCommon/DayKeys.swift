//
//  DayKeys.swift
//  Habits
//
//  Created by Michael Forrest on 28/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit

private func createDateKeyFormatter()->NSDateFormatter{
    let formatter = NSDateFormatter()
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}
private let dateKeyFormatter = createDateKeyFormatter()
private let gmt = NSTimeZone(forSecondsFromGMT: 0)
private let gmtCalendar = NSCalendar(calendarIdentifier: NSCalendar.currentCalendar().calendarIdentifier)

func dayKey(date:NSDate)->String{
    let formatter = dateKeyFormatter
    let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
    guard let calendar = gmtCalendar else { return "" }
    calendar.timeZone = gmt
    if let date = calendar.dateFromComponents(components){
        return formatter.stringFromDate(date)
    }else{
        return ""
    }
}
func dateFromKey(key:String)->NSDate?{
    return dateKeyFormatter.dateFromString(key)
}
func weekdayNameOfWeekdayComponent(weekday:Int)->String{
    return [
        "sun", "mon", "tue", "wed", "thu", "fri", "sat"
    ][weekday - 1]
}
func weekdayOfDate(date:NSDate)->String{
    let components = NSCalendar.currentCalendar().components(.Weekday, fromDate: date)
    return weekdayNameOfWeekdayComponent(components.weekday)
}
class DayKeys: NSObject {
    static func dateFromKey(key:String)->NSDate?{
        return dateFromKey(key)
    }
    static func keyFromDate(date:NSDate)->String{
        return keyFromDate(date)
    }
}
