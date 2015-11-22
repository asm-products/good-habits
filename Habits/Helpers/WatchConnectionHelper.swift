//
//  WatchConnectionHelper.swift
//  Habits
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import WatchConnectivity
import HabitsCommon

@available(iOS 9.0, *)
@objc class WatchConnectionHelper: NSObject, WCSessionDelegate {
    var session: WCSession
    
    override init(){
        session = WCSession.defaultSession()
        super.init()
        session.delegate = self
        session.activateSession()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHabitsUpdated", name: CHAIN_MODIFIED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHabitsUpdated", name: HABITS_UPDATED, object: nil)
    }
    func onHabitsUpdated(){
        do{
            try session.updateApplicationContext(latestData())
        }catch {
            print("couldn't update watch application context")
        }
    }
    func latestData()->[String:AnyObject]{
        let habits = HabitsQueries.activeToday() as! [Habit]
        let habitDicts:[[String:AnyObject]] = habits.map { habit in
            let state:DayCheckedState = habit.chainForDate(NSDate()).dayState()
            return [
                "identifier": habit.identifier,
                "title": habit.title,
                "order": habit.order,
                "state": Int(state.rawValue)
            ]
        }
        let info:[String:AnyObject] = ["habits":habitDicts]
//        var reminders = [[NSDate:Int]]()
//        let baseCount = habits.filter({$0.hasReminders() == false } ).count
//        let today = TimeHelper.startOfDayInUTC(NSDate())
//        for habit in habits.filter({$0.hasReminders()}){
//            let time = habit.reminderTime
//            
//            
//        }
//        info["reminders"] = reminders
        return info
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let habits = applicationContext["habits"] as? [[String:AnyObject]]{
            for dict in habits{
                updateHabitWithDict(dict)
            }
        }
    }
    func updateHabitWithDict(dict:[String:AnyObject]){
        let id = dict["identifier"] as! String
        let state = dict["state"] as! Int
        let dayCheckedState = DayCheckedState(rawValue: UInt32(state))
        if let habit = HabitsQueries.findHabitByIdentifier(id){
            habit.ensureDayCheckedStateForDate(NSDate(), dayState: dayCheckedState)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(REFRESH, object: nil)
        
    }
}
