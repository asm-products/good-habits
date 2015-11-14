//
//  DataRecoveryStoreTableViewCell.swift
//  Habits
//
//  Created by Michael Forrest on 06/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import HabitsCommon
class DataRecoveryStoreTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var client:CoreDataClient?{
        didSet{
            titleLabel.text = infoText(client!)
        }
    }
    
    func infoText(client:CoreDataClient)->String{
        let lastUsedDate = client.lastUsedDate()
        let formattedDate = lastUsedDate == NSDate(timeIntervalSince1970: 0) ? "never" : Moment(date: lastUsedDate).fromNowWithSuffix(true)
        let habits = client.allHabits() as! [Habit]
        return "\(habits.count) habit\(habits.count == 1 ? "" : "s"), used \(formattedDate)"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        addGestureRecognizer(longPress)
    }
    func handleLongPress(longPress:UILongPressGestureRecognizer){
        if longPress.state != .Began { return }
        if let habits = client?.allHabits() as? [Habit]{
            let titles = habits.map{ $0.title }
            let alert = UIAlertView(title: "Store Details", message: "\(titles)\n\(client!.persistentStore.URL!)", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
