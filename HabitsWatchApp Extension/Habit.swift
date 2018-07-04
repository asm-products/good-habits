//
//  Habit.swift
//  Habits
//
//  Created by Michael Forrest on 28/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
typealias HabitStructDictionary = [String:Any]
typealias AppContextFormat = [String:[String:[HabitStructDictionary]]]

enum HabitDayState:Int{ // maps to Chain->DayCheckedState
    case null = 0
    case complete = 1
    case broken = 2 
}

struct HabitStruct{
    var identifier: String
    var title: String
    var order: Int
    var color: UIColor?
    var state: HabitDayState = .null
    var updatedTime = Date()
    init(dict:[String:AnyObject]){
        identifier = dict["identifier"] as? String ?? "unknown"
        title = dict["title"] as? String ?? ""
        order = dict["order"] as? Int ?? 0
        color = NSKeyedUnarchiver.unarchiveObject(with: dict["color"] as? Data ?? Data()) as? UIColor
        if let stateInt = dict["state"] as? Int, let state = HabitDayState(rawValue: stateInt){
            self.state = state
        }
    }
    init(identifier:String, title: String, order: Int, color: UIColor, state: HabitDayState){
        self.identifier = identifier
        self.title = title
        self.order = order
        self.color = color
        self.state = state
    }
    func toDictionary()->HabitStructDictionary{
        return [
            "identifier": identifier,
            "title": title,
            "order": order,
            "color": NSKeyedArchiver.archivedData(withRootObject: color ?? UIColor.clear),
            "state": state.rawValue
        ]
    }
}
/*
context: [
    "habits": [
        "2015-01-23": [
        [
        "identifier": habit.identifier,
        "title": habit.title,
        "order": habit.order,
        "color": AVHexColor.hexStringFromColor(habit.color),
        "state": Int(state.rawValue)
        ]
        ],
        ...
    ],
    "templates": [
        "monday": [[
        "identifier": habit.identifier,
        "title": habit.title,
        "order": habit.order,
        "color": AVHexColor.hexStringFromColor(habit.color),
        ],
        ...
        ]
    ]
]
*/
