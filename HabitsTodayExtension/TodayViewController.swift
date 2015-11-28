//
//  TodayViewController.swift
//  HabitsTodayExtension
//
//  Created by Michael Forrest on 06/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import NotificationCenter
import HabitsCommon
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    var habits: [Habit]!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshHabits()
        
        for name in [NSUserDefaultsDidChangeNotification, NSExtensionHostWillEnterForegroundNotification]{
            NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
                self.refreshHabits()
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshHabits()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshHabits()
    }
    func onUserDefaultsChanged(){ // this is to synchronise between widget and app
        refreshHabits()
    }
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    func refreshHabits(){
        HabitsQueries.refresh()
        habits = HabitsQueries.activeToday() as! [Habit]
        tableView.reloadData()
        preferredContentSize = tableView.contentSize
//        let notification = UILocalNotification()
//        notification.applicationIconBadgeNumber = HabitsQueries.outstandingToday().count
//        notification.fireDate = NSDate()
    }
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let countBefore = habits.filter({$0.currentChain()?.dayState() == DayCheckedStateComplete}).count
        refreshHabits()
        let countAfter = habits.filter({$0.currentChain()?.dayState() == DayCheckedStateComplete}).count
        
        print("Count before \(countBefore) count after \(countAfter)")
        let result: NCUpdateResult = countAfter == countBefore ? .NoData : .NewData
        completionHandler(result)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("HabitCell", forIndexPath: indexPath) as! HabitCellTodayWidget
        cell.habit = habit
        return cell
    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        extensionContext?.openURL(NSURL(string: "goodhabits://list")!) { _ in
//            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//    }

}
