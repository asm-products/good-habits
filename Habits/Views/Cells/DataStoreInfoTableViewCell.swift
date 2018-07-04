//
//  DataStoreInfoTableViewCell.swift
//  Habits
//
//  Created by Michael Forrest on 11/08/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import HabitsCommon
class DataStoreInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    weak var delegate: UIViewController!
    var client: CoreDataClient!{
        didSet{
            populate()
        }
    }
    func populate(){
        label.text = client.persistentStore.url?.absoluteString
        fileInfoLabel.text = fileInfoText()
    }
    func fileInfoText()->String{
//        let request = NSFetchRequest(entityName: "Habit")
        let request = NSFetchRequest<Habit>(entityName: "Habit")
        let habits = (try! client.managedObjectContext.fetch(request)) 
        let nextRequiredDate = habits.reduce(Date(timeIntervalSince1970: 0), { (date, habit) -> Date in
            if let chain = habit.currentChain(){
                let nextRequiredDate = chain.nextRequiredDate()
                return nextRequiredDate != nil && (nextRequiredDate! > date) ? nextRequiredDate! : date
            }else{
                return date
            }
        })
        return "\(habits.count) habit(s), most recent \(nextRequiredDate)"
    }
    @IBAction func didPressExport(_ sender: AnyObject) {
        DataExport.run(delegate, client: client)
    }
}
