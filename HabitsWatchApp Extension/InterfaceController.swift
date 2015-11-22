//
//  InterfaceController.swift
//  HabitsWatchApp Extension
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import WatchKit
import Foundation

enum HabitDayState:Int{ // maps to Chain->DayCheckedState
    case Null
    case Complete
    case Broken
}

class InterfaceController: WKInterfaceController{

    @IBOutlet var habitsTable: WKInterfaceTable!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        NSNotificationCenter.defaultCenter().addObserverForName(UpdateNotificationName, object: nil, queue: nil) {  _ in
            self.refresh()
        }
        refresh()
    }
    var delegate: ExtensionDelegate{
        return WKExtension.sharedExtension().delegate as! ExtensionDelegate
    }
    func refresh(){
        if let context = delegate.applicationContext{
            showHabits(context)
        }
    }
    func showHabits(applicationContext:[String:AnyObject]){
        let habits = applicationContext["habits"] as! [[String:AnyObject]]
        habitsTable.setNumberOfRows(habits.count, withRowType: "Habit")
        
        for (index,habit) in habits.enumerate(){
            guard let id = habit["identifier"] as? String else { break }
            let row = habitsTable.rowControllerAtIndex(index) as! HabitWatchTableRowController
            row.identifier = id
            row.delegate = self
            row.titleLabel.setText(habit["title"] as? String)
            if let stateInt = habit["state"] as? Int, state = HabitDayState(rawValue: stateInt){
                row.setState(state)
            }
        }
    }
    func toggleStateForHabitRow(row:HabitWatchTableRowController, currentState: HabitDayState){
        var raw = currentState.rawValue
        raw += 1
        if raw > 2{ raw = 0 }
        let newState = HabitDayState(rawValue: raw)!
        row.setState(newState)
        delegate.updateHabit(row.identifier, state:newState)
        
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
