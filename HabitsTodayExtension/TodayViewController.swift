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
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }

        refreshHabits()
        
        for name in [UserDefaults.didChangeNotification, NSNotification.Name.NSExtensionHostWillEnterForeground]{
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: OperationQueue.main) { _ in
                self.refreshHabits()
            }
        }
    }
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        refreshHabits()
        preferredContentSize = CGSize(width: maxSize.width, height: min(tableView.contentSize.height, maxSize.height)) 
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshHabits()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHabits()
    }
    func onUserDefaultsChanged(){ // this is to synchronise between widget and app
        refreshHabits()
    }
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
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
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let countBefore = habits.filter({$0.currentChain()?.dayState() == .complete}).count
        refreshHabits()
        let countAfter = habits.filter({$0.currentChain()?.dayState() == .complete}).count
        
        print("Count before \(countBefore) count after \(countAfter)")
        let result: NCUpdateResult = countAfter == countBefore ? .noData : .newData
        completionHandler(result)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath) as! HabitCellTodayWidget
        cell.habit = habit
        return cell
    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        extensionContext?.openURL(NSURL(string: "goodhabits://list")!) { _ in
//            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//    }

}
