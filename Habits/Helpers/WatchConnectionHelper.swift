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
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
       
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    var session: WCSession
    
    override init(){
        session = WCSession.default
        super.init()
        session.delegate = self
        session.activate()
        NotificationCenter.default.addObserver(self, selector: #selector(WatchConnectionHelper.onHabitsUpdated), name: NSNotification.Name(rawValue: CHAIN_MODIFIED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WatchConnectionHelper.onHabitsUpdated), name: NSNotification.Name(rawValue: HABITS_UPDATED), object: nil)
    }
    @objc func onHabitsUpdated(){
        do{
            try session.updateApplicationContext(latestData())
        }catch {
            print("couldn't update watch application context")
        }
    }
    func habitStructFromHabit(_ habit:Habit, order:Int)->HabitStruct{
        return HabitStruct(
            identifier: habit.identifier,
            title: habit.title,
            order: order,
            color: habit.color,
            state: HabitDayState(rawValue: Int(habit.findOrCreateChain(for: Date()).dayState().rawValue)) ?? .null
        )
    }
    func habitDaysWithJustToday()->[String: [HabitStructDictionary]]{
        let habits = HabitsQueries.activeToday()
        var order = 0
        let habitDicts = habits.map { habit->HabitStructDictionary in
            order += 1
            return habitStructFromHabit(habit, order: order).toDictionary()
        }
        return [dayKey(Date()): habitDicts]
    }
    func dayTemplates()->[String:[HabitStructDictionary]]{ // fuck, this is a bit weird - should just send the list of habits with the days they're needed
        let habits:[Habit] = HabitsQueries.active()
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
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let context = applicationContext as? AppContextFormat, let dates = context["habits"] else {
                print("Failed to parse habits from application context \(applicationContext)")
            return
        }
        for (dateKey, habits) in dates{
            if let date = dateFromKey(dateKey){
                for habit in habits.map({ HabitStruct(dict: $0 as [String : AnyObject])}) {
                    self.updateHabitWithStruct(habit, date: date)
                }
            }else{
                print("Error! Unknown date \(dateKey)")
            }
        }
    }
    func updateHabitWithStruct(_ source:HabitStruct, date: Date){
        let state = UInt(source.state.rawValue)
       
        if let dayCheckedState = DayCheckedState(rawValue: state),  let habit = HabitsQueries.findHabit(byIdentifier: source.identifier){
            habit.ensureDayCheckedState(for: date, dayState: dayCheckedState)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: REFRESH), object: nil)
        
    }
}
