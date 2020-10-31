//
//  DayKeys.swift
//  Habits
//
//  Created by Michael Forrest on 28/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit

private func createDateKeyFormatter()->DateFormatter{
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}
private let dateKeyFormatter = createDateKeyFormatter()
private let gmt = TimeZone(secondsFromGMT: 0)
private let gmtCalendar = Calendar(identifier: Calendar.current.identifier)

func dayKey(_ date:Date)->String{
    let formatter = dateKeyFormatter
    let components = (Calendar.current as NSCalendar).components([.year, .month, .day], from: date)
    var calendar = gmtCalendar// else { return "" }
    calendar.timeZone = gmt!
    if let date = calendar.date(from: components){
        return formatter.string(from: date)
    }else{
        return ""
    }
}
func dateFromKey(_ key:String)->Date?{
    return dateKeyFormatter.date(from: key)
}
func _dateFromKey(_ key:String)->Date?{
    return dateFromKey(key)
}
func weekdayNameOfWeekdayComponent(_ weekday:Int)->String{
    return [
        "sun", "mon", "tue", "wed", "thu", "fri", "sat"
    ][weekday - 1]
}
func weekdayOfDate(_ date:Date)->String{
    let components = (Calendar.current as NSCalendar).components(.weekday, from: date)
    return weekdayNameOfWeekdayComponent(components.weekday!)
}
@objc open class DayKeys: NSObject {
    @objc static public func convertKeyToDate(_ key:String)->Date?{
        return _dateFromKey(key)
    }
    @objc static public func convertDateToKey(_ date:Date)->String{
        return dayKey(date)
    }
}
