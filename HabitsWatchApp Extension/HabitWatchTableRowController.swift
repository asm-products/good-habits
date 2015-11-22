//
//  HabitWatchTableRowController.swift
//  Habits
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import WatchKit

class HabitWatchTableRowController: NSObject {
    var identifier: String!
    weak var delegate:InterfaceController!
    var state:HabitDayState!
    @IBOutlet var checkButton: WKInterfaceButton!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBAction func didPressCheckButton() {
        delegate.toggleStateForHabitRow(self, currentState: state)
    }
    func setState(state:HabitDayState){
        switch state{
        case .Complete:
            checkButton.setTitle("✓")
        case .Broken:
            checkButton.setTitle("╳")
        case .Null:
            checkButton.setTitle("")
        }
        self.state = state
    }
}
