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

func today()->Date{
    let components = (Calendar.current as NSCalendar).components([.year,.month,.day], from: Date())
    return Calendar.current.date(from: components)!
}

class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        applicationDidBecomeActive() // ??
    }

    var session:WCSession!
    var currentDay: Date?
    var todaysHabits: [String:HabitStruct]?
    var applicationContext: [String:AnyObject]?{
        didSet{
            saveApplicationContextToLocalStorage()
            populateTodayFromApplicationContext()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateNotificationName), object: nil)
            }
        }
    }
    func applicationDidFinishLaunching() {
        loadApplicationStateFromLocalStorage()
        session = WCSession.default
        session.delegate = self
        session.activate()
    }
    func applicationDidBecomeActive() {
        if today() != currentDay{
            print("Day changed from \(currentDay) to \(today()), repopulating")
            populateTodayFromApplicationContext()
        }
    }
    func populateTodayFromApplicationContext(){
        guard let context = applicationContext as? AppContextFormat, let habits = context["habits"], let templates = context["templates"]  else {
            print("ERROR - bad context format \(applicationContext)")
            return
        }
        todaysHabits = [String:HabitStruct]()
        let key = dayKey(Date())
        print("loading habits for \(key)")
        if let todaysHabits = habits[key] {
            // found today in the context
            print("found in the current context")
            for habit in todaysHabits.map({HabitStruct(dict: $0 as [String : AnyObject])}){
                self.todaysHabits![habit.identifier] = habit
            }
        }else{
            // need to create today from a template and add it to the context
            let weekday = weekdayOfDate(Date()) // e.g. "mon"
            let template = templates[weekday]! // crash if we don't get this. because wtf.
            print("creating from template \(template)")
            for habit in template.map({HabitStruct(dict: $0 as [String : AnyObject])}){
                var habit = habit
                habit.state = .null
                self.todaysHabits![habit.identifier] = habit
            }
        }
        currentDay = today()
        NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateNotificationName), object: nil)
        updateComplication()
    }
    private func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationContext = applicationContext
        print("received app context")
    }
    fileprivate var storeURL:URL{
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.goodtohear.habits")!.appendingPathComponent("ApplicationContext.plist")
    }
    func loadApplicationStateFromLocalStorage(){
        print("Load from \(storeURL)")
        applicationContext = NSDictionary(contentsOf: storeURL) as! [String:AnyObject]?
    }
    func saveApplicationContextToLocalStorage(){
        if let context = applicationContext{
            print("Save to \(storeURL)")
            let dictionary = NSDictionary(dictionary: context)
            dictionary.write(toFile: storeURL.path, atomically: true)
        }
    }
    func storeHabitUpdate(_ habit:HabitStruct){
        guard var context = applicationContext as? AppContextFormat, var _ = context["habits"] else {
            print("no application context found on which to update state!")
            return
        }
        todaysHabits![habit.identifier] = habit
        let todaysHabitsDictArray = todaysHabits!.map({$1.toDictionary()})
        context["habits"]![dayKey(Date())] = todaysHabitsDictArray
        self.applicationContext = context as [String : AnyObject]?
        do{
            try session.updateApplicationContext(context)
        }catch{
            print("Couldn't update application context")
        }
        updateComplication()
    }
    func updateComplication(){
        let server = CLKComplicationServer.sharedInstance()
        if let complications = server.activeComplications{
            for complication in complications{
                server.reloadTimeline(for: complication)
            }
        }
    }
    func reminderCountsAfterDate(_ date:Date, limit:Int)->[ReminderTime]{
        guard let context = applicationContext as? AppContextFormat, let templates = context["templates"]  else {
            print("No templates found for complication after date \(date)")
            return []
        }
        print("getting reminder counts after \(date)")
        var date = today()
        var oneDay = DateComponents()
        oneDay.day = 1
        let result = [currentCount() ?? ReminderTime(Date(), 0)] + (1...2).map { n->ReminderTime in
            let weekday = weekdayOfDate(date)
            let template = templates[weekday]!
            let count = template.count
            date = (Calendar.current as NSCalendar).date(byAdding: oneDay, to: date, options: [])!
            return ReminderTime(date, count)
        }
        print("counts for timeline \(result)")
        return result
    }
    func currentCount()->ReminderTime?{
        guard let todaysHabits = todaysHabits else { return nil }
        let count = todaysHabits.reduce(0) { (memo, pair) -> Int in
            let (_, habit) = pair
            if habit.state != .complete{
                return memo + 1
            }else {
                return memo
            }
        }
        let result = ReminderTime(Date(), count)
        if todaysHabits.count > 0{
            result.progress = Float(todaysHabits.count - count) / Float(todaysHabits.count)
        }
        return result
    }
    func handleAction(withIdentifier identifier: String?, for localNotification: UILocalNotification) {
        
    }
    func handleAction(withIdentifier identifier: String?, for localNotification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any]) {
        
    }
}
class ReminderTime:CustomStringConvertible{
    var count: Int
    var date: Date
    var progress:Float?
    init(_ date:Date, _ count: Int){
        self.date = date
        self.count = count
    }
    var description:String{
        return "ReminderTime: \(date):\(count)"
    }
}
