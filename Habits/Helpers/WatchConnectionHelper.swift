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
    func habitStructFromHabit(habit:Habit)->HabitStruct{
        return HabitStruct(
            identifier: habit.identifier,
            title: habit.title,
            order: Int(habit.order),
            color: habit.color,
            state: HabitDayState(rawValue: Int(habit.chainForDate(NSDate()).dayState().rawValue))!
        )
    }
    func habitDaysWithJustToday()->[String: [HabitStructDictionary]]{
        let habits = HabitsQueries.activeToday() as! [Habit]
        let habitDicts = habits.map {
            habitStructFromHabit($0).toDictionary()
        }
        return [dayKey(NSDate()): habitDicts]
    }
    func dayTemplates()->[String:[HabitStructDictionary]]{ // fuck, this is a bit weird - should just send the list of habits with the days they're needed
        let habits = HabitsQueries.active() as! [Habit]
        var result = [String:[HabitStructDictionary]]()
        for day in (1...7){
            result[weekdayNameOfWeekdayComponent(day)] =
                habits.filter({
                    Bool($0.daysRequired[day-1] as! NSNumber)
                }).map {
                    habitStructFromHabit($0).toDictionary()
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
            habit.ensureDayCheckedStateForDate(NSDate(), dayState: dayCheckedState)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(REFRESH, object: nil)
        
    }
}
