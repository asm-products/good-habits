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
    
    func infoText(_ client:CoreDataClient)->String{
        let lastUsedDate = client.lastUsedDate()
        let formattedDate = lastUsedDate == Date(timeIntervalSince1970: 0) ? "never" : Moment(date: lastUsedDate).fromNow(withSuffix: true)
        let habits = client.allHabits() as! [Habit]
        return "\(habits.count) habit\(habits.count == 1 ? "" : "s"), used \(formattedDate)"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(DataRecoveryStoreTableViewCell.handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    @objc func handleLongPress(_ longPress:UILongPressGestureRecognizer){
        if longPress.state != .began { return }
        if let habits = client?.allHabits() as? [Habit]{
            let titles = habits.map{ $0.title }
            let alert = UIAlertView(title: "Store Details", message: "\(titles)\n\(client!.persistentStore.url!)", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
