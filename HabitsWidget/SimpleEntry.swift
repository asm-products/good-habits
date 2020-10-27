//
//  SimpleEntry.swift
//  HabitsWidgetExtension
//
//  Created by Michael Forrest on 22/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import Foundation
import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [HabitProxy]
    let completedHabits: Int
    let totalHabits: Int
    let imageName: String
    
    let allDoneSoFar: Bool
    let habitsNeededSoFar: [HabitProxy]
    let habitsNeededLater: [HabitProxy]
    
    init(date: Date, habits: [HabitProxy]){
        self.date = date
        self.habits = habits
        self.completedHabits = self.habits.filter{$0.state == .complete}.count
        self.totalHabits = self.habits.count
        self.imageName = totalHabits == completedHabits ? "checkmark.seal.fill" :  "checkmark"
        
        habitsNeededSoFar = habits.filter{ proxy in
            guard let time = proxy.reminderTimeToday else { return true }
            return time <= date
        }
        habitsNeededLater = habits.filter{$0.state != .complete}.filter{ proxy in
            guard let time = proxy.reminderTimeToday else { return false}
            return time > date
        }
        allDoneSoFar = habitsNeededSoFar.filter({ $0.state == .complete}).count == habitsNeededSoFar.count && habits.count > 0
    }
}
