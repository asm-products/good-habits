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
    var habitsKeyedByIdentifier = [String:[String:AnyObject]]()
    var applicationContext: [String:AnyObject]?{
        didSet{
            saveApplicationContextToLocalStorage()
            populateHabitsFromApplicationContext()
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
    func populateHabitsFromApplicationContext(){
        guard let context = applicationContext, habits = context["habits"] as? [[String:AnyObject]] else {return}
        for habit in habits{
            if let id = habit["identifier"] as? String{
                habitsKeyedByIdentifier[id] = habit
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
    func updateHabit(id:String, state:HabitDayState){
        guard var context = applicationContext else {
            print("no application context found on which to update state!")
            return
        }
        var habit = habitsKeyedByIdentifier[id]!
        habit["state"] = state.rawValue
        habitsKeyedByIdentifier[id] = habit
        context["habits"] = habitsKeyedByIdentifier.keys.map({ self.habitsKeyedByIdentifier[$0]! }).sort({ $0["order"] as? Int ?? 0 > $1["order"] as? Int ?? 0})
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
        let count = habitsKeyedByIdentifier.reduce(0) { (memo, pair) -> Int in
            let (_, habit) = pair
            if habit["state"] as? Int != HabitDayState.Complete.rawValue{
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