//
//  InterfaceController.swift
//  HabitsWatchApp Extension
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import WatchKit
import Foundation

class WatchHabitsListController: WKInterfaceController{

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
        guard let habits = delegate.todaysHabits else { return }
        habitsTable.setNumberOfRows(habits.count, withRowType: "Habit")
        for (index,(_,habit)) in habits.sort({ $0.1.order < $1.1.order}).enumerate(){
            let row = habitsTable.rowControllerAtIndex(index) as! HabitWatchTableRowController
            row.habit = habit
            row.delegate = self
            row.titleLabel.setText(habit.title)
            row.color = habit.color
            row.setState(habit.state)
        }
    }
    func toggleStateForHabitRow(row:HabitWatchTableRowController, currentState: HabitDayState){
        var raw = currentState.rawValue
        raw += 1
        if raw > 2{ raw = 0 }
        let newState = HabitDayState(rawValue: raw)!
        row.setState(newState)
        row.habit.state = newState
        delegate.storeHabitUpdate(row.habit)
        
    }
    override func willActivate() {
        super.willActivate()
        if delegate.todaysHabits == nil {
            pushControllerWithName("PleaseLaunchHabits", context: nil)
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
