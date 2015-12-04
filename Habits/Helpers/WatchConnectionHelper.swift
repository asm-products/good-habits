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
    func habitStructFromHabit(habit:Habit, order:Int)->HabitStruct{
        return HabitStruct(
            identifier: habit.identifier,
            title: habit.title,
            order: order,
            color: habit.color,
            state: HabitDayState(rawValue: Int(habit.chainForDate(NSDate()).dayState().rawValue))!
        )
    }
    func habitDaysWithJustToday()->[String: [HabitStructDictionary]]{
        let habits = HabitsQueries.activeToday() as! [Habit]
        var order = 0
        let habitDicts = habits.map { habit->HabitStructDictionary in
            order += 1
            return habitStructFromHabit(habit, order: order).toDictionary()
        }
        return [dayKey(NSDate()): habitDicts]
    }
    func dayTemplates()->[String:[HabitStructDictionary]]{ // fuck, this is a bit weird - should just send the list of habits with the days they're needed
        let habits = HabitsQueries.active() as! [Habit]
        var result = [String:[HabitStructDictionary]]()
        var order = 0
        for day in (1...7){
            result[weekdayNameOfWeekdayComponent(day)] =
                habits.filter({
                    Bool($0.daysRequired[day-1] as! NSNumber)
                }).map { habit in
                    order += 1
                    // this results in a slightly odd 'global' ordering but it gives the desired result on the watch
                    // and all we save when the watch gives back data is the dayCheckedState so it won't get sucked back in
                    return habitStructFromHabit(habit, order: order).toDictionary()
                }
        }
        return result
    }
    func latestData()->AppContextFormat{
        // just need to add today when creating the latest data
        let info:AppContextFormat = [
            "habits": habitDaysWithJustToday(),
            "templates": dayTemplates()
        ]
        return info
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        guard let context = applicationContext as? AppContextFormat, dates = context["habits"] else {
                print("Failed to parse habits from application context \(applicationContext)")
            return
        }
        for (dateKey, habits) in dates{
            if let date = dateFromKey(dateKey){
                for habit in habits.map({ HabitStruct(dict: $0)}) {
                    self.updateHabitWithStruct(habit, date: date)
                }
            }else{
                print("Error! Unknown date \(dateKey)")
            }
        }
    }
    func updateHabitWithStruct(source:HabitStruct, date: NSDate){
        let state = UInt32(source.state.rawValue)
        let dayCheckedState = DayCheckedState(rawValue: state)
        if let habit = HabitsQueries.findHabitByIdentifier(source.identifier){
            habit.ensureDayCheckedStateForDate(date, dayState: dayCheckedState)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(REFRESH, object: nil)
        
    }
}
