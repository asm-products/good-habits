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


class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {
    var session:WCSession!
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
    func populateTodayFromApplicationContext(){
        guard let context = applicationContext as? AppContextFormat, habits = context["habits"], templates = context["templates"]  else {
            print("ERROR - bad context format \(applicationContext)")
            return
        }
        todaysHabits = [String:HabitStruct]()
        if let todaysHabits = habits[dayKey(NSDate())] {
            // found today in the context
            for habit in todaysHabits.map({HabitStruct(dict: $0)}){
                self.todaysHabits![habit.identifier] = habit
            }
        }else{
            // need to create today from a template and add it to the context
            let weekday = weekdayOfDate(NSDate()) // e.g. "mon"
            let template = templates[weekday]! // crash if we don't get this. because wtf.
            for habit in template.map({HabitStruct(dict: $0)}){
                self.todaysHabits![habit.identifier] = habit
            }
            
        }
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
        guard var context = applicationContext as? AppContextFormat, habits = context["habits"] else {
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
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    func reminderCountsAfterDate(date:NSDate, limit:Int)->[ReminderTime]{
        return []
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
        return ReminderTime(NSDate(), count)
    }
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        
    }
    func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject]) {
        
    }
}
class ReminderTime{
    var count: Int
    var date: NSDate
    init(_ date:NSDate, _ count: Int){
        self.date = date
        self.count = count
    }
}