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
    case header
    case store
    case count
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
            self.performSegue(withIdentifier: "Continue", sender: self)
        }
    }
    @IBAction func didPressContinue(_ sender: AnyObject) {
        SVProgressHUD.show()
        dataRecovery.migrateSelectedStoreToSharedContainer {
            SVProgressHUD.dismiss()
            self.finished()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)!{
        case .header: return 1
        case .store: return dataRecovery.clients.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch Section(rawValue: (indexPath as NSIndexPath).section)!{
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! MigrationHeaderCell
            if let text = self.descriptionText{
                cell.descriptionLabel.text = text
            }
            return cell
        case .store:
           let cell = tableView.dequeueReusableCell(withIdentifier: "Store", for: indexPath) as! DataRecoveryStoreTableViewCell
           cell.client = dataRecovery.clients[(indexPath as NSIndexPath).row]
           cell.accessoryType = dataRecovery.selectedStoreIndex == (indexPath as NSIndexPath).row ? .checkmark : .none
           return cell
        default: return UITableViewCell() // meh
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Section(rawValue: (indexPath as NSIndexPath).section)! == .store{
            dataRecovery.selectedStoreIndex = (indexPath as NSIndexPath).row
            tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if Section(rawValue: section)! == .store{
            return tableView.dequeueReusableCell(withIdentifier: "Footer")?.contentView
        }else{
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Section(rawValue: section)! == .store && dataRecovery.clients.count > 0{
            return 40
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return Section(rawValue: (indexPath as NSIndexPath).section)! == .store
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if Section(rawValue: (indexPath as NSIndexPath).section) == .store{
            
            let export = UITableViewRowAction(style: .normal, title: "Export") { (action, indexPath) -> Void in
                let client = self.dataRecovery.clients[(indexPath as NSIndexPath).row]
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
