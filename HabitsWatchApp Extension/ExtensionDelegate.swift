//
//  ExtensionDelegate.swift
//  HabitsWatchApp Extension
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import WatchKit
import WatchConnectivity
import ClockKit
let UpdateNotificationName = "UPDATE"

func today()->NSDate{
    let components = NSCalendar.currentCalendar().components([.Year,.Month,.Day], fromDate: NSDate())
    return NSCalendar.currentCalendar().dateFromComponents(components)!
}

class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {
    var session:WCSession!
    var currentDay: NSDate?
    var todaysHabits: [String:HabitStruct]?
    var applicationContext: [String:AnyObject]?{
        didSet{
            saveApplicationContextToLocalStorage()
            populateTodayFromApplicationContext()
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotificationName, object: nil)
            }
        }
    }
    func applicationDidFinishLaunching() {
        loadApplicationStateFromLocalStorage()
        session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }
    func applicationDidBecomeActive() {
        if today() != currentDay{
            populateTodayFromApplicationContext()
        }
    }
    func populateTodayFromApplicationContext(){
        guard let context = applicationContext as? AppContextFormat, habits = context["habits"], templates = context["templates"]  else {
            print("ERROR - bad context format \(applicationContext)")
            return
        }
        todaysHabits = [String:HabitStruct]()
        let key = dayKey(NSDate())
        print("loading habits for \(key)")
        if let todaysHabits = habits[key] {
            // found today in the context
            print("found in the current context")
            for habit in todaysHabits.map({HabitStruct(dict: $0)}){
                self.todaysHabits![habit.identifier] = habit
            }
        }else{
            // need to create today from a template and add it to the context
            let weekday = weekdayOfDate(NSDate()) // e.g. "mon"
            let template = templates[weekday]! // crash if we don't get this. because wtf.
            print("creating from template \(template)")
            for habit in template.map({HabitStruct(dict: $0)}){
                var habit = habit
                habit.state = .Null
                self.todaysHabits![habit.identifier] = habit
            }
        }
        currentDay = today()
        NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotificationName, object: nil)
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationContext = applicationContext
        print("context = \(applicationContext)")
    }
    private var storeURL:NSURL{
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.goodtohear.habits")!.URLByAppendingPathComponent("ApplicationContext.plist")
    }
    func loadApplicationStateFromLocalStorage(){
        print("Load from \(storeURL)")
        applicationContext = NSDictionary(contentsOfURL: storeURL) as! [String:AnyObject]?
    }
    func saveApplicationContextToLocalStorage(){
        if let context = applicationContext{
            print("Save to \(storeURL)")
            let dictionary = NSDictionary(dictionary: context)
            dictionary.writeToFile(storeURL.path!, atomically: true)
        }
    }
    func storeHabitUpdate(habit:HabitStruct){
        guard var context = applicationContext as? AppContextFormat, _ = context["habits"] else {
            print("no application context found on which to update state!")
            return
        }
        todaysHabits![habit.identifier] = habit
        let todaysHabitsDictArray = todaysHabits!.map({$1.toDictionary()})
        context["habits"]![dayKey(NSDate())] = todaysHabitsDictArray
        self.applicationContext = context
        do{
            try session.updateApplicationContext(context)
        }catch{
            print("Couldn't update application context")
        }
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications{
            server.reloadTimelineForComplication(complication)
        }
        
    }

    func reminderCountsAfterDate(date:NSDate, limit:Int)->[ReminderTime]{
        guard let context = applicationContext as? AppContextFormat, templates = context["templates"]  else {
            print("No templates found for complication after date \(date)")
            return []
        }
        print("getting reminder counts after \(date)")
        var date = today()
        let oneDay = NSDateComponents()
        oneDay.day = 1
        let result = [currentCount() ?? ReminderTime(today(), 0)] + (1...2).map { n->ReminderTime in
            let weekday = weekdayOfDate(date)
            let template = templates[weekday]!
            let count = template.count
            date = NSCalendar.currentCalendar().dateByAddingComponents(oneDay, toDate: date, options: [])!
            return ReminderTime(date, count)
        }
        print("counts for timeline \(result)")
        return result
    }
    func currentCount()->ReminderTime?{
        guard let todaysHabits = todaysHabits else { return nil }
        let count = todaysHabits.reduce(0) { (memo, pair) -> Int in
            let (_, habit) = pair
            if habit.state != .Complete{
                return memo + 1
            }else {
                return memo
            }
        }
        let result = ReminderTime(today(), count)
        if todaysHabits.count > 0{
            result.progress = Float(todaysHabits.count - count) / Float(todaysHabits.count)
        }
        return result
    }
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        
    }
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject]) {
        
    }
}
class ReminderTime:CustomStringConvertible{
    var count: Int
    var date: NSDate
    var progress:Float?
    init(_ date:NSDate, _ count: Int){
        self.date = date
        self.count = count
    }
    var description:String{
        return "ReminderTime: \(date):\(count)"
    }
}