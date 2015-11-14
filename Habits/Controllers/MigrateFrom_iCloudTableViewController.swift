//
//  MigrateFrom_iCloudTableViewController.swift
//  Habits
//
//  Created by Michael Forrest on 06/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import HabitsCommon
private enum Section: Int{
    case Header
    case Store
    case Count
}
@objc public protocol MigrateFrom_iCloudTableViewControllerDelegate{
    func dismissDataMigration()
}

class MigrationHeaderCell:UITableViewCell{
    @IBOutlet weak var descriptionLabel: UILabel!
}

class MigrateFrom_iCloudTableViewController: UITableViewController {
    var dataRecovery = DataRecovery()
    var delegate: MigrateFrom_iCloudTableViewControllerDelegate?
    
    var descriptionText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataRecovery.isNotRequired{
            if delegate == nil {
                self.finished()
            }
            dataRecovery.migrationIgnored()
        }else if dataRecovery.hasOnlyOneOption{
            dataRecovery.migrateSelectedStoreToSharedContainer {
                self.finished()
            }
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        if dataRecovery.clients.count == 0{
            navigationItem.rightBarButtonItem = nil
        }
    }
    func finished(){
        if let delegate = self.delegate{
            delegate.dismissDataMigration()
        }else{
            self.performSegueWithIdentifier("Continue", sender: self)
        }
    }
    @IBAction func didPressContinue(sender: AnyObject) {
        SVProgressHUD.show()
        dataRecovery.migrateSelectedStoreToSharedContainer {
            SVProgressHUD.dismiss()
            self.finished()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.Count.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)!{
        case .Header: return 1
        case .Store: return dataRecovery.clients.count
        default: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch Section(rawValue: indexPath.section)!{
        case .Header:
            let cell = tableView.dequeueReusableCellWithIdentifier("Header", forIndexPath: indexPath) as! MigrationHeaderCell
            if let text = self.descriptionText{
                cell.descriptionLabel.text = text
            }
            return cell
        case .Store:
           let cell = tableView.dequeueReusableCellWithIdentifier("Store", forIndexPath: indexPath) as! DataRecoveryStoreTableViewCell
           cell.client = dataRecovery.clients[indexPath.row]
           cell.accessoryType = dataRecovery.selectedStoreIndex == indexPath.row ? .Checkmark : .None
           return cell
        default: return UITableViewCell() // meh
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if Section(rawValue: indexPath.section)! == .Store{
            dataRecovery.selectedStoreIndex = indexPath.row
            tableView.reloadData()
        }
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if Section(rawValue: section)! == .Store{
            return tableView.dequeueReusableCellWithIdentifier("Footer")?.contentView
        }else{
            return nil
        }
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Section(rawValue: section)! == .Store && dataRecovery.clients.count > 0{
            return 40
        }else{
            return 0
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return Section(rawValue: indexPath.section)! == .Store
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if Section(rawValue: indexPath.section) == .Store{
            
            let export = UITableViewRowAction(style: .Normal, title: "Export") { (action, indexPath) -> Void in
                let client = self.dataRecovery.clients[indexPath.row]
                DataExport.run(self, client: client)
            }
            export.backgroundColor = Colors.green()
            return [ export ]
        }else{
            return nil
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
