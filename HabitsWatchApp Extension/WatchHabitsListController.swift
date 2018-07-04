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
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: UpdateNotificationName), object: nil, queue: nil) {  _ in
            self.refresh()
        }
        refresh()
    }
    var delegate: ExtensionDelegate{
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    func refresh(){
        guard let habits = delegate.todaysHabits else { return }
        habitsTable.setNumberOfRows(habits.count, withRowType: "Habit")
        for (offset: index, element: (key: _,value: habit)) in habits.sorted(by: { $0.1.order < $1.1.order}).enumerated(){
            let row = habitsTable.rowController(at: index) as! HabitWatchTableRowController
            row.habit = habit
            row.delegate = self
            row.titleLabel.setText(habit.title)
            row.color = habit.color
            row.setState(habit.state)
        }
    }
    func toggleStateForHabitRow(_ row:HabitWatchTableRowController, currentState: HabitDayState){
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
            pushController(withName: "PleaseLaunchHabits", context: nil)
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
