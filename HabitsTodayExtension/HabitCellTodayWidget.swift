//
//  HabitCellTodayWidget.swift
//  Habits
//
//  Created by Michael Forrest on 06/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import HabitsCommon
class HabitCellTodayWidget: UITableViewCell {

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countCell: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        countCell.backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        checkBox.addGestureRecognizer(tap)
        
    }
    func handleTap(tap:UITapGestureRecognizer){
        let toggler = HabitToggler()
        let state = toggler.toggleTodayForHabit(habit)
        checkBox.state = state
        
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    var habit:Habit!{
        didSet{
            titleLabel.text = habit.title
            checkBox.color = habit.color
            if let chain = habit.currentChain(){
                checkBox.state = chain.dayState()
                let daysOverdue = chain.countOfDaysOverdue()
                if daysOverdue > 0{
                    countCell.setBackgroundImage(AwardImage.circleColored(Colors.cobalt()), forState: .Normal)
                    countCell.setTitle("-\(daysOverdue)", forState: .Normal)
                }else{
                    countCell.setTitle("\(chain.daysCountCache)", forState: .Normal)
                    countCell.setBackgroundImage(chain.isRecord() ? AwardImage.starColored(habit.color) : AwardImage.circleColored(habit.color), forState: .Normal)
                }
            }
        }
    }

}
