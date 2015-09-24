//
//  DataStoreInfoTableViewCell.swift
//  Habits
//
//  Created by Michael Forrest on 11/08/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class DataStoreInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    var client: CoreDataClient!{
        didSet{
            populate()
        }
    }
    func populate(){
        label.text = client.persistentStore.URL?.absoluteString
        fileInfoLabel.text = fileInfoText()
    }
    func fileInfoText()->String{
        let request = NSFetchRequest(entityName: "Habit")
        let habits = client.managedObjectContext.executeFetchRequest(request, error: nil) as! [Habit]
        let nextRequiredDate = habits.reduce(NSDate(timeIntervalSince1970: 0), combine: { (date, habit) -> NSDate in
            if let chain = habit.currentChain(){
                return chain.nextRequiredDate().laterDate(date)
            }else{
                return date
            }
        })
        return "\(habits.count) habit(s), most recent \(nextRequiredDate)"
    }
}
